// Copyright (c) 2021 Dmitry Meduho
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import AppKit
import EquinoxCore
import ImageIO

struct ImportedWallpaperItem {
    let url: URL
    let azimuth: Double?
    let altitude: Double?
    let time: Date?
}

// MARK: - Protocols

protocol ImageProvider {
    func loadImage(
        url: URL,
        resizeMode: ImageResizeMode,
        completion: @escaping (NSImage?) -> Void
    )
    func validateImages(_ urls: [URL]) -> [URL]
    func getImageMetadata(for url: URL) -> ExifMetadata?
    func getWallpaperItems(for url: URL) -> [ImportedWallpaperItem]?
}

// MARK: - Enums, Structs

enum ImageResizeMode {
    case source
    case resized(size: NSSize, respectAspect: Bool)
}

// MARK: - Class

final class ImageProviderImpl: ImageProvider {
    private let imageService: ImageService
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    // MARK: - Initializer

    init(imageService: ImageService) {
        self.imageService = imageService
    }
    
    // MARK: - Public

    func loadImage(url: URL, resizeMode: ImageResizeMode, completion: @escaping (NSImage?) -> Void) {
        if let cachedImage = imageService.retrieveCachedImage(url: url) {
            completion(cachedImage)
            return
        }
        operationQueue.addOperation { [weak self] in
            guard let self = self else {
                return
            }
            guard let image = NSImage(contentsOf: url) else {
                OperationQueue.main.addOperation {
                    completion(nil)
                }
                return
            }

            let size: NSSize

            switch resizeMode {
            case .source:
                size = image.size

            case .resized(let newSize, let respectAspect):
                if respectAspect {
                    let imageAspect = image.size.width / image.size.height
                    let resizeAspect = newSize.width / newSize.height

                    if imageAspect < resizeAspect {
                        size = .init(width: newSize.width, height: newSize.width / imageAspect)
                    } else {
                        size = .init(width: newSize.width / imageAspect, height: newSize.height)
                    }
                } else {
                    size = newSize
                }
            }

            let resizedImage = self.imageService.resizeImage(image: image, size: size)
            self.imageService.cacheImage(url: url, image: resizedImage)

            OperationQueue.main.addOperation {
                completion(resizedImage)
            }
        }
    }

    func validateImages(_ urls: [URL]) -> [URL] {
        var preparedUrls: [URL] = []

        for url in urls where imageService.validateImage(url: url, imageFormat: ImageFormatType.allCases) {
            preparedUrls.append(url)
        }

        return preparedUrls
    }

    func getImageMetadata(for url: URL) -> ExifMetadata? {
        do {
            let metadata = try imageService.getImageMetadata(for: url)
            return metadata
        } catch {
            return nil
        }
    }

    func getWallpaperItems(for url: URL) -> [ImportedWallpaperItem]? {
        guard
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let imageMetadata = readWallpaperMetadata(source: source)
        else {
            return nil
        }

        if let solarMetadata = imageMetadata.solarMetadata {
            let sortedMetadata = solarMetadata.sorted { $0.index < $1.index }
            return sortedMetadata.compactMap {
                guard let exportedURL = exportImage(source: source, index: $0.index, originalURL: url) else {
                    return nil
                }
                return ImportedWallpaperItem(url: exportedURL, azimuth: $0.azimuth, altitude: $0.altitude, time: nil)
            }
        }

        if let timeMetadata = imageMetadata.timeMetadata {
            let sortedMetadata = timeMetadata.sorted { $0.index < $1.index }
            return sortedMetadata.compactMap {
                guard let exportedURL = exportImage(source: source, index: $0.index, originalURL: url) else {
                    return nil
                }
                return ImportedWallpaperItem(
                    url: exportedURL,
                    azimuth: nil,
                    altitude: nil,
                    time: makeDate(from: $0.time)
                )
            }
        }

        return nil
    }

    private func readWallpaperMetadata(source: CGImageSource) -> ImportedImageMetadata? {
        guard
            let metadata = CGImageSourceCopyMetadataAtIndex(source, 0, nil),
            let tags = CGImageMetadataCopyTags(metadata) as? [CGImageMetadataTag]
        else {
            return nil
        }

        for type in ImportedImageMetadataType.allCases {
            guard
                let tag = tags.first(where: { CGImageMetadataTagCopyName($0) as String? == type.rawValue }),
                let tagValue = CGImageMetadataTagCopyValue(tag) as? String,
                let decodedValue = Data(base64Encoded: tagValue)
            else {
                continue
            }

            let decoder = PropertyListDecoder()
            return try? decoder.decode(ImportedImageMetadata.self, from: decodedValue)
        }

        return nil
    }

    private func exportImage(source: CGImageSource, index: Int, originalURL: URL) -> URL? {
        guard
            index < CGImageSourceGetCount(source),
            let image = CGImageSourceCreateImageAtIndex(source, index, nil),
            let sourceType = CGImageSourceGetType(source)
        else {
            return nil
        }

        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("equinox-import-\(UUID().uuidString)", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        } catch {
            return nil
        }

        let fileExtension = originalURL.pathExtension.isEmpty ? "heic" : originalURL.pathExtension
        let filename = String(format: "%03d.%@", index, fileExtension)
        let outputURL = temporaryDirectory.appendingPathComponent(filename)

        guard let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, sourceType, 1, nil) else {
            return nil
        }

        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }

        return outputURL
    }

    private func makeDate(from time: Double) -> Date {
        let calendar = getCurrentCalendar
        let startOfDay = calendar.startOfDay(for: Date())
        let seconds = Int(round(time * Double(24 * 60 * 60)))
        return calendar.date(byAdding: .second, value: seconds, to: startOfDay) ?? startOfDay
    }
}

private enum ImportedImageMetadataType: String, CaseIterable {
    case solar = "solar"
    case time = "h24"
}

private struct ImportedImageMetadata: Decodable {
    let solarMetadata: [ImportedSolarMetadata]?
    let timeMetadata: [ImportedTimeMetadata]?

    enum CodingKeys: String, CodingKey {
        case solarMetadata = "si"
        case timeMetadata = "ti"
    }
}

private struct ImportedSolarMetadata: Decodable {
    let index: Int
    let altitude: Double
    let azimuth: Double

    enum CodingKeys: String, CodingKey {
        case index = "i"
        case altitude = "a"
        case azimuth = "z"
    }
}

private struct ImportedTimeMetadata: Decodable {
    let index: Int
    let time: Double

    enum CodingKeys: String, CodingKey {
        case index = "i"
        case time = "t"
    }
}
