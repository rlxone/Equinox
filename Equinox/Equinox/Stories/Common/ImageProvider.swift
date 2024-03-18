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

// MARK: - Protocols

protocol ImageProvider {
    func loadImage(
        url: URL,
        resizeMode: ImageResizeMode,
        completion: @escaping (NSImage?) -> Void
    )
    func validateImages(_ urls: [URL]) -> [URL]
    func getImageMetadata(for url: URL) -> ExifMetadata?
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
}
