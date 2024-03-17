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

import Foundation

// MARK: - Protocols

public protocol WallpaperService {
    func createWallpaper(_ attributes: [ImageAttributes], progressCallback: ProgressCallback?) throws -> Data
}

// MARK: - Class

public final class WallpaperServiceImpl: WallpaperService {
    private let metadataCore: MetadataCore
    private let imageCore: ImageCore
    
    // MARK: - Initializer
    
    public init(metadataCore: MetadataCore, imageCore: ImageCore) {
        self.metadataCore = metadataCore
        self.imageCore = imageCore
    }
    
    // MARK: - Public

    public func createWallpaper(_ attributes: [ImageAttributes], progressCallback: ProgressCallback?) throws -> Data {
        let preparedAttrubutes = prepareAttributes(attributes)
        let metadata = try metadataCore.generate(from: preparedAttrubutes)
        let image = try imageCore.createImage(from: preparedAttrubutes, metadata: metadata, progressCallback: progressCallback)
        return image
    }
    
    // MARK: - Private

    private func prepareAttributes(_ attributes: [ImageAttributes]) -> [ImageAttributes] {
        guard attributes.count > 1 else {
            return attributes
        }

        var mutableAttributes = attributes
        var newAttributes: [ImageAttributes] = []

        guard let firstIndex = mutableAttributes.firstIndex(where: { $0.primary }) else {
            return mutableAttributes
        }

        let primaryAttribute = mutableAttributes.remove(at: firstIndex)
        mutableAttributes.insert(primaryAttribute, at: 0)

        for (index, attribute) in mutableAttributes.enumerated() {
            newAttributes.append(
                .init(
                    url: attribute.url,
                    index: index,
                    primary: attribute.primary,
                    imageType: attribute.imageType,
                    appearanceType: attribute.appearanceType
                )
            )
        }

        return newAttributes
    }
}
