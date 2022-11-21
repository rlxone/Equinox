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

import EquinoxCore
import XCTest

class ImageCacheCoreTests: XCTestCase {
    private var imageCacheCore: ImageCacheCoreImpl!

    override func setUpWithError() throws {
        imageCacheCore = ImageCacheCoreImpl(totalCostLimit: 512 * 1_024 * 1_024)
    }

    func testCache() {
        // Given
        let retrieveKey = "test"
        let image = NSImage(size: .init(width: 300, height: 300))

        // When
        imageCacheCore.cache(key: retrieveKey, data: image)
        let retrievedImage = imageCacheCore.retrieve(key: retrieveKey)

        // Then
        XCTAssertNotNil(retrievedImage)
    }

    func testRetrieve() {
        // Given
        let testKey = "test"
        let dummyKey = "dummy"
        let image = NSImage(size: .init(width: 300, height: 300))

        // When
        imageCacheCore.cache(key: testKey, data: image)
        let testImage = imageCacheCore.retrieve(key: testKey)
        let dummyImage = imageCacheCore.retrieve(key: dummyKey)

        // Then
        XCTAssertNotNil(testImage)
        XCTAssertNil(dummyImage)
    }

    func testRemove() {
        // Given
        let testKey = "test"
        let dummyKey = "dummy"
        let image = NSImage(size: .init(width: 300, height: 300))

        // When
        imageCacheCore.cache(key: testKey, data: image)
        imageCacheCore.remove(key: testKey)
        imageCacheCore.remove(key: dummyKey)
        let testImage = imageCacheCore.retrieve(key: testKey)
        let dummyImage = imageCacheCore.retrieve(key: dummyKey)

        // Then
        XCTAssertNil(testImage)
        XCTAssertNil(dummyImage)
    }

    func testClear() {
        // Given
        let testKey1 = "test1"
        let testKey2 = "test2"
        let testKey3 = "test3"
        let image1 = NSImage(size: .init(width: 300, height: 300))
        let image2 = NSImage(size: .init(width: 400, height: 400))
        let image3 = NSImage(size: .init(width: 500, height: 500))

        // When
        imageCacheCore.cache(key: testKey1, data: image1)
        imageCacheCore.cache(key: testKey2, data: image2)
        imageCacheCore.cache(key: testKey3, data: image3)
        imageCacheCore.clear()
        let retrievedImage1 = imageCacheCore.retrieve(key: testKey1)
        let retrievedImage2 = imageCacheCore.retrieve(key: testKey2)
        let retrievedImage3 = imageCacheCore.retrieve(key: testKey3)

        // Then
        XCTAssertNil(retrievedImage1)
        XCTAssertNil(retrievedImage2)
        XCTAssertNil(retrievedImage3)
    }
}
