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

struct TestMetadata: Codable {
    struct Pair: Codable {
        let key: String
        let value: String
    }
    
    let metadata: [Pair]
}

class MetadataCoreTests: XCTestCase {
    private var metadataCore: MetadataCoreImpl!
    private lazy var testBundle = Bundle(for: type(of: self))
    
    override func setUpWithError() throws {
        metadataCore = MetadataCoreImpl()
    }
    
    func testGenerateSolarMetadata() throws {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "heic")!
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
        let result = getTestMetadata(key: "solar.metadata")
        
        // When
        let metadata = try metadataCore.generate(from: imageAttributes)
        let tags = CGImageMetadataCopyTags(metadata) as? [CGImageMetadataTag]
        let solarTag = tags?.first { CGImageMetadataTagCopyName($0) == ImageMetadataType.solar.rawValue as CFString }
        let tag = try XCTUnwrap(solarTag)
        let tagValue = try XCTUnwrap(CGImageMetadataTagCopyValue(tag) as? String)
        
        // Then
        XCTAssertNotNil(metadata)
        XCTAssertEqual(tagValue, result)
    }
    
    func testGenerateTimeSmallMetadata() throws {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "heic")!
        let url = URL(fileURLWithPath: path)
        let imageAttributes: [ImageAttributes] = [
            ImageAttributes(
                url: url,
                index: 0,
                primary: true,
                imageType: .time(date: try getDate(day: 20, month: 10, year: 2_020, hour: 12, minute: 0, second: 0)),
                appearanceType: .light
            ),
            ImageAttributes(
                url: url,
                index: 1,
                primary: false,
                imageType: .time(date: try getDate(day: 20, month: 10, year: 2_020, hour: 13, minute: 0, second: 0)),
                appearanceType: .dark
            )
        ]
        let result = getTestMetadata(key: "time.small.metadata")
        
        // When
        let metadata = try metadataCore.generate(from: imageAttributes)
        let tags = CGImageMetadataCopyTags(metadata) as? [CGImageMetadataTag]
        let timeTag = tags?.first { CGImageMetadataTagCopyName($0) == ImageMetadataType.time.rawValue as CFString }
        let tag = try XCTUnwrap(timeTag)
        let tagValue = try XCTUnwrap(CGImageMetadataTagCopyValue(tag) as? String)
        
        // Then
        XCTAssertNotNil(metadata)
        XCTAssertEqual(tagValue, result)
    }
    
    func testGenerateTimeLargeMetadata() throws {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "heic")!
        let url = URL(fileURLWithPath: path)
        let imagesCount = 24 * 12
        var imageAttributes: [ImageAttributes] = []
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "GMT") ?? .current
        let startOfDate = calendar.startOfDay(for: Date())
        let oneDaysSeconds = 24 * 60 * 60
        let oneImageInterval = oneDaysSeconds / imagesCount
        
        for index in 0..<imagesCount {
            let value = oneImageInterval * index
            guard let date = calendar.date(byAdding: .second, value: value, to: startOfDate) else {
                continue
            }
            imageAttributes.append(
                ImageAttributes(
                    url: url,
                    index: index,
                    primary: index == 0,
                    imageType: .time(date: date),
                    appearanceType: nil
                )
            )
        }
        let result = getTestMetadata(key: "time.large.metadata")
        
        // When
        let metadata = try metadataCore.generate(from: imageAttributes)
        let tags = CGImageMetadataCopyTags(metadata) as? [CGImageMetadataTag]
        let timeTag = tags?.first { CGImageMetadataTagCopyName($0) == ImageMetadataType.time.rawValue as CFString }
        let tag = try XCTUnwrap(timeTag)
        let tagValue = try XCTUnwrap(CGImageMetadataTagCopyValue(tag) as? String)
        
        // Then
        XCTAssertNotNil(metadata)
        XCTAssertEqual(tagValue, result)
    }
    
    func testGenerateAppearanceMetadata() throws {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "heic")!
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
        let result = getTestMetadata(key: "appearance.metadata")
        
        // When
        let metadata = try metadataCore.generate(from: imageAttributes)
        let tags = CGImageMetadataCopyTags(metadata) as? [CGImageMetadataTag]
        let appearanceTag = tags?.first { CGImageMetadataTagCopyName($0) == ImageMetadataType.appearance.rawValue as CFString }
        let tag = try XCTUnwrap(appearanceTag)
        let tagValue = try XCTUnwrap(CGImageMetadataTagCopyValue(tag) as? String)
        
        // Then
        XCTAssertNotNil(metadata)
        XCTAssertEqual(tagValue, result)
    }
    
    func testImageMetadata() {
        // Given
        let path = testBundle.path(forResource: "image", ofType: "heic")!
        let url = URL(fileURLWithPath: path)
        
        // When
        let metadata = try? metadataCore.getImageMetadata(for: url)
        
        // Then
        XCTAssertNotNil(metadata)
        XCTAssertNotNil(metadata?.longitude)
        XCTAssertNotNil(metadata?.latitude)
        XCTAssertNotNil(metadata?.createDate)
    }
    
    private func getTestMetadata(key: String) -> String? {
        let path = testBundle.path(forResource: "metadata", ofType: "json")!
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            let jsonData = try JSONDecoder().decode(TestMetadata.self, from: data)
            return jsonData.metadata
                .first { $0.key == key }?
                .value
        } catch {
            return nil
        }
    }
    
    private func getDate(day: Int, month: Int, year: Int, hour: Int, minute: Int, second: Int) throws -> Date {
        let timezone = TimeZone(abbreviation: "GMT") ?? .current
        
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        dateComponents.timeZone = timezone
        
        var calendar = Calendar.current
        calendar.timeZone = timezone
        
        let date = calendar.date(from: dateComponents)!
        return date
    }
}
