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
import AVFoundation

// MARK: - Protocols

public typealias ProgressCallback = (Int, Int) -> Void

public protocol ImageCore {
    func createImage(
        from attributes: [ImageAttributes],
        metadata: CGImageMetadata,
        progressCallback: ProgressCallback?
    ) throws -> Data
    func getImageFormat(for url: URL) throws -> ImageFormatType
    func resizeImage(image: NSImage, size: NSSize) -> NSImage
    func validateImage(_ url: URL, imageFormat: [ImageFormatType]) -> Bool
}

// MARK: - Enums, Structs

extension ImageCoreImpl {
    private enum ImageHeaderSignature {
        static let png: [UInt8] = [0x89]
        static let jpeg: [UInt8] = [0xFF]
        static let tiff1: [UInt8] = [0x49]
        static let tiff2: [UInt8] = [0x4D]
        static let heic: [UInt8] = [0x66, 0x74, 0x79, 0x70, 0x68, 0x65, 0x69, 0x63]
    }

    private enum Constants {
        static let heicOffset = 4
    }
}

// MARK: - Class

public final class ImageCoreImpl: ImageCore {
    public init() {
    }
    
    // MARK: - Public

    public func createImage(
        from attributes: [ImageAttributes],
        metadata: CGImageMetadata,
        progressCallback: ProgressCallback?
    ) throws -> Data {
        let mutableData = NSMutableData()
        let destinationType = AVFileType.heic as CFString
        let options = [kCGImageDestinationLossyCompressionQuality: lossyCompressionQuality] as CFDictionary

        guard let destination = CGImageDestinationCreateWithData(mutableData, destinationType, attributes.count, nil) else {
            throw ImageError.destinationNotCreated
        }
        
        let steps = attributes.count + 1

        for (index, attribute) in attributes.enumerated() {
            let image = try readImage(from: attribute.url)

            if index == 0 {
                CGImageDestinationAddImageAndMetadata(destination, image, metadata, options)
            } else {
                CGImageDestinationAddImage(destination, image, options)
            }

            let step = index + 1
            progressCallback?(step, steps)
        }

        guard CGImageDestinationFinalize(destination) else {
            throw ImageError.invalidImageFormat
        }

        progressCallback?(steps, steps)

        return mutableData as Data
    }
        
    public func resizeImage(image: NSImage, size: NSSize) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(
            in: .init(origin: .zero, size: size),
            from: .init(origin: .zero, size: image.size),
            operation: .copy,
            fraction: 1
        )
        newImage.unlockFocus()
        return newImage
    }
    
    public func getImageFormat(for url: URL) throws -> ImageFormatType {
        var data: Data
        let signatureLength = 1

        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ImageError.dataNotObtained
        }

        guard !data.isEmpty else {
            throw ImageError.invalidImageFormat
        }

        var buffer = [UInt8](repeating: 0, count: signatureLength)
        data.copyBytes(to: &buffer, count: signatureLength)

        switch buffer {
        case ImageHeaderSignature.png:
            return .png

        case ImageHeaderSignature.jpeg:
            return .jpeg

        case ImageHeaderSignature.tiff1, ImageHeaderSignature.tiff2:
            return .tiff

        default:
            var heicBuffer = [UInt8](repeating: 0, count: ImageHeaderSignature.heic.count)
            let lowerbound = Constants.heicOffset
            let upperbound = lowerbound + ImageHeaderSignature.heic.count
            let range = lowerbound..<upperbound
            data.copyBytes(to: &heicBuffer, from: range)
            if heicBuffer == ImageHeaderSignature.heic {
                return .heic
            }
            throw ImageError.invalidImageFormat
        }
    }

    public func validateImage(_ url: URL, imageFormat: [ImageFormatType]) -> Bool {
        do {
            let format = try getImageFormat(for: url)
            return imageFormat.contains(format)
        } catch {
            return false
        }
    }
    
    // MARK: - Private
    
    private func readImage(from url: URL) throws -> CGImage {
        guard let image = NSImage(contentsOf: url) else {
            throw ImageError.invalidImageFormat
        }
        return try convertImage(image)
    }

    private func convertImage(_ image: NSImage) throws -> CGImage {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw ImageError.imageNotConverted
        }
        return cgImage
    }

    private var lossyCompressionQuality: Double {
        let lossless = 1.0
        let lossy = 0.999_999_9

        // This works around a bug in macOS 14.4.1 and later where encoding HEIC on Intel devices fails.
        //
        // See https://github.com/rlxone/Equinox/pull/69
        #if arch(x86_64)
        if #unavailable(macOS 14.4.1) {
            return lossless
        }

        if #unavailable(macOS 15) {
            return lossy
        }

        #else
        // Fallthrough

        #endif

        return lossless
    }
}
