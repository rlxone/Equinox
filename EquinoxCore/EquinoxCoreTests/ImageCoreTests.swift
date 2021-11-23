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

// swiftlint:disable force_unwrapping

class ImageCoreTests: XCTestCase {
    private var imageCore: ImageCoreImpl!
    private lazy var testBundle = Bundle(for: type(of: self))
    
    override func setUpWithError() throws {
        imageCore = ImageCoreImpl()
    }
    
    func testCreateSolarImage() throws {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "png")!
        let url = URL(fileURLWithPath: path)
        let imageAttributes: [ImageAttributes] = [
            ImageAttributes(
                url: url,
                index: 0,
                primary: true,
                imageType: .solar(altitude: 55, azimuth: 55),
                appearanceType: .light
            ),
            ImageAttributes(
                url: url,
                index: 1,
                primary: false,
                imageType: .solar(altitude: 44, azimuth: 44),
                appearanceType: .dark
            )
        ]
        
        let metadataCore = MetadataCoreImpl()
        let metadata = try XCTUnwrap(try metadataCore.generate(from: imageAttributes))
        
        // When
        let image = try imageCore.createImage(from: imageAttributes, metadata: metadata, progressCallback: nil)
        
        // Then
        XCTAssertNotNil(image)
    }
    
    func testCreateTimeImage() throws {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "png")!
        let url = URL(fileURLWithPath: path)
        let imageAttributes: [ImageAttributes] = [
            ImageAttributes(
                url: url,
                index: 0,
                primary: true,
                imageType: .time(date: Date()),
                appearanceType: .light
            ),
            ImageAttributes(
                url: url,
                index: 1,
                primary: false,
                imageType: .time(date: Date()),
                appearanceType: .dark
            )
        ]
        
        let metadataCore = MetadataCoreImpl()
        let metadata = try XCTUnwrap(try metadataCore.generate(from: imageAttributes))
        
        // When
        let image = try imageCore.createImage(from: imageAttributes, metadata: metadata, progressCallback: nil)
        
        // Then
        XCTAssertNotNil(image)
    }
    
    func testCreateAppearanceImage() throws {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "png")!
        let url = URL(fileURLWithPath: path)
        let imageAttributes: [ImageAttributes] = [
            ImageAttributes(
                url: url,
                index: 0,
                primary: true,
                imageType: .appearance,
                appearanceType: .light
            ),
            ImageAttributes(
                url: url,
                index: 1,
                primary: false,
                imageType: .appearance,
                appearanceType: .dark
            )
        ]
        
        let metadataCore = MetadataCoreImpl()
        let metadata = try XCTUnwrap(try metadataCore.generate(from: imageAttributes))
        
        // When
        let image = try imageCore.createImage(from: imageAttributes, metadata: metadata, progressCallback: nil)
        
        // Then
        XCTAssertNotNil(image)
    }
    
    func testGetImageFormat() throws {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "heic")!
        let url = URL(fileURLWithPath: path)
        let result = ImageFormatType.heic
        
        // When
        let format = try imageCore.getImageFormat(for: url)
        
        // Then
        XCTAssertEqual(format, result)
    }
    
    func testValidateImage() throws {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "heic")!
        let url = URL(fileURLWithPath: path)
        
        // When
        let result = imageCore.validateImage(url, imageFormat: [.heic])
        
        // Then
        XCTAssertTrue(result)
    }
    
    func testResizeImage() throws {
        // Given
        let image = NSImage(size: .init(width: 300, height: 300))
        
        // When
        let result = imageCore.resizeImage(image: image, size: .init(width: 200, height: 200))
        
        // Then
        XCTAssertEqual(result.size, result.size)
    }
}
