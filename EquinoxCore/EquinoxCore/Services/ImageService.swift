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

// MARK: - Protocols

public protocol ImageService {
    func resizeImage(image: NSImage, size: NSSize) -> NSImage
    func cacheImage(url: URL, image: NSImage)
    func retrieveCachedImage(url: URL) -> NSImage?
    func removeCachedImage(url: URL)
    func validateImage(url: URL, imageFormat: [ImageFormatType]) -> Bool
    func getImageMetadata(for url: URL) throws -> ExifMetadata
}

// MARK: - Class

public final class ImageServiceImpl: ImageService {
    private let metadataCore: MetadataCore
    private let imageCore: ImageCore
    private let imageCacheCore: ImageCacheCore

    // MARK: - Initializer

    public init(metadataCore: MetadataCore, imageCore: ImageCore, imageCacheCore: ImageCacheCore) {
        self.metadataCore = metadataCore
        self.imageCore = imageCore
        self.imageCacheCore = imageCacheCore
    }

    // MARK: - Public

    public func resizeImage(image: NSImage, size: NSSize) -> NSImage {
        return imageCore.resizeImage(image: image, size: size)
    }

    public func cacheImage(url: URL, image: NSImage) {
        let key = url.absoluteString
        imageCacheCore.cache(key: key, data: image)
    }

    public func retrieveCachedImage(url: URL) -> NSImage? {
        let key = url.absoluteString

        guard let image = imageCacheCore.retrieve(key: key) else {
            return nil
        }

        return image
    }

    public func removeCachedImage(url: URL) {
        let key = url.absoluteString
        imageCacheCore.remove(key: key)
    }

    public func validateImage(url: URL, imageFormat: [ImageFormatType]) -> Bool {
        return imageCore.validateImage(url, imageFormat: imageFormat)
    }

    public func getImageMetadata(for url: URL) throws -> ExifMetadata {
        return try metadataCore.getImageMetadata(for: url)
    }
}
