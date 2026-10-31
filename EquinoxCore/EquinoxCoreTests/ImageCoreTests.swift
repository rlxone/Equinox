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

@testable import EquinoxCore
import ImageIO
import XCTest

class ImageCoreTests: XCTestCase {
    private var imageCore: ImageCoreImpl!
    private lazy var testBundle = Bundle(for: type(of: self))
    
    override func setUpWithError() throws {
        imageCore = ImageCoreImpl()
    }
    
    func testCreateSolarImage() throws {
        // Given
        // swiftlint:disable:next force_unwrapping
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
        // swiftlint:disable:next force_unwrapping
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
        // swiftlint:disable:next force_unwrapping
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

    func testCreateImageFromHEICSource() throws {
        // Given
        // swiftlint:disable:next force_unwrapping
        let path = testBundle.path(forResource: "image", ofType: "heic")!
        let url = URL(fileURLWithPath: path)
        let imageAttributes = [
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
        let metadata = try MetadataCoreImpl().generate(from: imageAttributes)

        // When
        let data = try imageCore.createImage(
            from: imageAttributes,
            metadata: metadata,
            progressCallback: nil
        )

        // Then
        let source = try XCTUnwrap(
            CGImageSourceCreateWithData(data as CFData, nil)
        )
        XCTAssertEqual(CGImageSourceGetCount(source), 2)
        for index in 0..<2 {
            XCTAssertNotNil(CGImageSourceCreateImageAtIndex(source, index, nil))
        }
        let outputPayload = try XCTUnwrap(
            HEIFMuxer.primaryCodedPayload(in: data)
        )
        let sourcePayload = try XCTUnwrap(
            HEIFMuxer.primaryCodedPayload(in: try Data(contentsOf: url))
        )
        XCTAssertEqual(outputPayload, sourcePayload)

        let extracted = try ImageCoreImpl().extractHEICFrame(
            from: data,
            at: 1
        )
        let extractedSource = try XCTUnwrap(
            CGImageSourceCreateWithData(extracted as CFData, nil)
        )
        XCTAssertEqual(CGImageSourceGetCount(extractedSource), 1)
        XCTAssertEqual(
            HEIFMuxer.primaryCodedPayload(in: extracted),
            outputPayload
        )

        let output = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("heic")
        try data.write(to: output)
        defer { try? FileManager.default.removeItem(at: output) }
        let wallpaper = try MetadataCoreImpl().readWallpaper(at: output)
        XCTAssertEqual(wallpaper.attributes.count, 2)
        XCTAssertEqual(wallpaper.attributes.map(\.sourceIndex), [0, 1])

        let copied = try imageCore.createImage(
            from: wallpaper.attributes,
            metadata: MetadataCoreImpl().generate(from: wallpaper.attributes),
            progressCallback: nil
        )
        let copiedSource = try XCTUnwrap(
            CGImageSourceCreateWithData(copied as CFData, nil)
        )
        XCTAssertEqual(CGImageSourceGetCount(copiedSource), 2)
    }

    func testCreateImagePreservesHEICFrameInMixedSources() throws {
        // Given
        // swiftlint:disable:next force_unwrapping
        let heicPath = testBundle.path(forResource: "image", ofType: "heic")!
        // swiftlint:disable:next force_unwrapping
        let pngPath = testBundle.path(forResource: "image", ofType: "png")!
        let heicURL = URL(fileURLWithPath: heicPath)
        let pngURL = URL(fileURLWithPath: pngPath)
        let attributes = [
            ImageAttributes(
                url: pngURL,
                index: 0,
                primary: true,
                imageType: .appearance,
                appearanceType: .light
            ),
            ImageAttributes(
                url: heicURL,
                index: 1,
                primary: false,
                imageType: .appearance,
                appearanceType: .dark
            )
        ]
        let metadata = try XCTUnwrap(
            try MetadataCoreImpl().generate(from: attributes)
        )
        let originalPayload = try XCTUnwrap(
            HEIFMuxer.primaryCodedPayload(in: try Data(contentsOf: heicURL))
        )

        // When
        let data = try imageCore.createImage(
            from: attributes,
            metadata: metadata,
            progressCallback: nil
        )

        // Then
        let source = try XCTUnwrap(
            CGImageSourceCreateWithData(data as CFData, nil)
        )
        XCTAssertEqual(CGImageSourceGetCount(source), 2)
        XCTAssertNotNil(CGImageSourceCreateImageAtIndex(source, 0, nil))
        XCTAssertNotNil(CGImageSourceCreateImageAtIndex(source, 1, nil))

        let preservedFrame = try imageCore.extractHEICFrame(
            from: data,
            at: 1
        )
        XCTAssertEqual(
            HEIFMuxer.primaryCodedPayload(in: preservedFrame),
            originalPayload
        )

        let lowQuality = try imageCore.createImage(
            from: attributes,
            metadata: metadata,
            settings: ImageExportSettings(
                lossyCompressionScope: .allImages,
                imageQuality: 25
            ),
            progressCallback: nil
        )
        let highQuality = try imageCore.createImage(
            from: attributes,
            metadata: metadata,
            settings: ImageExportSettings(
                lossyCompressionScope: .allImages,
                imageQuality: 90
            ),
            progressCallback: nil
        )
        let lowQualitySource = try XCTUnwrap(
            CGImageSourceCreateWithData(lowQuality as CFData, nil)
        )
        let highQualitySource = try XCTUnwrap(
            CGImageSourceCreateWithData(highQuality as CFData, nil)
        )
        XCTAssertEqual(CGImageSourceGetCount(lowQualitySource), 2)
        XCTAssertEqual(CGImageSourceGetCount(highQualitySource), 2)
        let lowQualityPNG = try imageCore.extractHEICFrame(
            from: lowQuality,
            at: 0
        )
        let highQualityPNG = try imageCore.extractHEICFrame(
            from: highQuality,
            at: 0
        )
        XCTAssertNotEqual(
            HEIFMuxer.primaryCodedPayload(in: lowQualityPNG),
            HEIFMuxer.primaryCodedPayload(in: highQualityPNG)
        )
        let recompressedHEIC = try imageCore.extractHEICFrame(
            from: lowQuality,
            at: 1
        )
        XCTAssertNotEqual(
            HEIFMuxer.primaryCodedPayload(in: recompressedHEIC),
            originalPayload
        )
    }
    
    func testExportSettingsClampQuality() {
        // Given / When
        let low = ImageExportSettings(imageQuality: -1)
        let high = ImageExportSettings(imageQuality: 100)
        let normal = ImageExportSettings(imageQuality: 42)

        // Then
        XCTAssertEqual(low.imageQuality, 1)
        XCTAssertEqual(high.imageQuality, 99)
        XCTAssertEqual(normal.imageQuality, 42)
        XCTAssertEqual(
            ImageExportSettings.default.lossyCompressionScope,
            .lossyFormatsButHEIC
        )
        XCTAssertEqual(ImageExportSettings.default.imageQuality, 80)
    }

    func testExtractHEICFrameRejectsInvalidIndicesAndData() throws {
        // Given
        let url = try XCTUnwrap(testBundle.url(
            forResource: "image", withExtension: "heic"
        ))
        let data = try Data(contentsOf: url)
        let source = try XCTUnwrap(
            CGImageSourceCreateWithData(data as CFData, nil)
        )

        // When / Then
        XCTAssertThrowsError(try imageCore.extractHEICFrame(
            from: data, at: -1
        ))
        XCTAssertThrowsError(try imageCore.extractHEICFrame(
            from: data, at: CGImageSourceGetCount(source)
        ))
        XCTAssertThrowsError(try imageCore.extractHEICFrame(
            from: Data([0, 1, 2]), at: 0
        ))
    }

    func testCompressionScopesPreserveHEICAndApplyQualityToPNG() throws {
        // Given
        let heicURL = try XCTUnwrap(testBundle.url(
            forResource: "image", withExtension: "heic"
        ))
        let pngURL = try XCTUnwrap(testBundle.url(
            forResource: "image", withExtension: "png"
        ))
        let attributes = [
            ImageAttributes(url: pngURL, index: 0, primary: true,
                            imageType: .appearance, appearanceType: .light),
            ImageAttributes(url: heicURL, index: 1, primary: false,
                            imageType: .appearance, appearanceType: .dark)
        ]
        let metadata = try MetadataCoreImpl().generate(from: attributes)
        let original = try XCTUnwrap(HEIFMuxer.primaryCodedPayload(
            in: Data(contentsOf: heicURL)
        ))

        func export(_ scope: LossyCompressionScope, _ quality: Int)
            throws -> [Data] {
            let data = try imageCore.createImage(
                from: attributes, metadata: metadata,
                settings: ImageExportSettings(
                    lossyCompressionScope: scope, imageQuality: quality
                ),
                progressCallback: nil
            )
            return try (0..<2).map { index in
                let frame = try imageCore.extractHEICFrame(
                    from: data, at: index
                )
                return try XCTUnwrap(HEIFMuxer.primaryCodedPayload(in: frame))
            }
        }

        // When
        let allButHEICLow = try export(.allButHEIC, 25)
        let allButHEICHigh = try export(.allButHEIC, 90)
        let lossyLow = try export(.lossyFormatsButHEIC, 25)
        let lossyHigh = try export(.lossyFormatsButHEIC, 90)
        let noneLow = try export(.noImages, 25)
        let noneHigh = try export(.noImages, 90)

        // Then
        XCTAssertNotEqual(allButHEICLow[0], allButHEICHigh[0])
        XCTAssertEqual(lossyLow[0], lossyHigh[0])
        XCTAssertEqual(noneLow[0], noneHigh[0])
        for frames in [allButHEICLow, allButHEICHigh, lossyLow,
                       lossyHigh, noneLow, noneHigh] {
            XCTAssertEqual(frames[1], original)
        }
    }

    func testLossyFormatScopeAppliesQualityToJPEG() throws {
        // Given
        let pngURL = try XCTUnwrap(testBundle.url(
            forResource: "image", withExtension: "png"
        ))
        let heicURL = try XCTUnwrap(testBundle.url(
            forResource: "image", withExtension: "heic"
        ))
        let source = try XCTUnwrap(CGImageSourceCreateWithURL(
            pngURL as CFURL, nil
        ))
        let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(
            source, 0, nil
        ))
        let jpegData = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(
            jpegData, "public.jpeg" as CFString, 1, nil
        ))
        CGImageDestinationAddImage(destination, image, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        let jpegURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("jpg")
        try (jpegData as Data).write(to: jpegURL)
        defer { try? FileManager.default.removeItem(at: jpegURL) }
        let attributes = [
            ImageAttributes(url: jpegURL, index: 0, primary: true,
                            imageType: .appearance, appearanceType: .light),
            ImageAttributes(url: heicURL, index: 1, primary: false,
                            imageType: .appearance, appearanceType: .dark)
        ]
        let metadata = try MetadataCoreImpl().generate(from: attributes)

        func export(_ scope: LossyCompressionScope, _ quality: Int)
            throws -> Data {
            let data = try imageCore.createImage(
                from: attributes, metadata: metadata,
                settings: ImageExportSettings(
                    lossyCompressionScope: scope, imageQuality: quality
                ),
                progressCallback: nil
            )
            let frame = try imageCore.extractHEICFrame(from: data, at: 0)
            return try XCTUnwrap(HEIFMuxer.primaryCodedPayload(in: frame))
        }

        // When / Then
        XCTAssertNotEqual(
            try export(.lossyFormatsButHEIC, 25),
            try export(.lossyFormatsButHEIC, 90)
        )
        XCTAssertEqual(try export(.noImages, 25), try export(.noImages, 90))
    }

    func testExportReportsProgressForEachFrameAndCompletion() throws {
        // Given
        let url = try XCTUnwrap(testBundle.url(
            forResource: "image", withExtension: "heic"
        ))
        let attributes = [
            ImageAttributes(url: url, index: 0, primary: true,
                            imageType: .appearance, appearanceType: .light),
            ImageAttributes(url: url, index: 1, primary: false,
                            imageType: .appearance, appearanceType: .dark)
        ]
        let metadata = try MetadataCoreImpl().generate(from: attributes)
        var steps: [Int] = []
        var totals: [Int] = []

        // When
        _ = try imageCore.createImage(
            from: attributes, metadata: metadata,
            progressCallback: { step, total in
                steps.append(step)
                totals.append(total)
            }
        )

        // Then
        XCTAssertEqual(steps, [1, 2, 3])
        XCTAssertEqual(totals, [3, 3, 3])
    }

    func testReorderAndAddDistinctHEICFrames() throws {
        // Given
        let heicURL = try XCTUnwrap(testBundle.url(
            forResource: "image", withExtension: "heic"
        ))
        let pngURL = try XCTUnwrap(testBundle.url(
            forResource: "image", withExtension: "png"
        ))
        let pngSource = try XCTUnwrap(CGImageSourceCreateWithURL(
            pngURL as CFURL, nil
        ))
        let pngImage = try XCTUnwrap(CGImageSourceCreateImageAtIndex(
            pngSource, 0, nil
        ))
        let secondData = NSMutableData()
        let destination = try XCTUnwrap(CGImageDestinationCreateWithData(
            secondData, "public.heic" as CFString, 1, nil
        ))
        CGImageDestinationAddImage(destination, pngImage, nil)
        XCTAssertTrue(CGImageDestinationFinalize(destination))
        let secondURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("heic")
        try (secondData as Data).write(to: secondURL)
        defer { try? FileManager.default.removeItem(at: secondURL) }
        let originalPayloads = try [heicURL, secondURL].map { url in
            try XCTUnwrap(HEIFMuxer.primaryCodedPayload(
                in: Data(contentsOf: url)
            ))
        }
        XCTAssertNotEqual(originalPayloads[0], originalPayloads[1])
        let attributes = [
            ImageAttributes(url: heicURL, index: 0, primary: true,
                            imageType: .solar(altitude: 10, azimuth: 20),
                            appearanceType: .light),
            ImageAttributes(url: secondURL, index: 1, primary: false,
                            imageType: .solar(altitude: 30, azimuth: 40),
                            appearanceType: .dark)
        ]
        let service = WallpaperServiceImpl(
            metadataCore: MetadataCoreImpl(), imageCore: imageCore
        )
        let first = try service.createWallpaper(
            attributes, progressCallback: nil
        )
        let firstURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("heic")
        try first.write(to: firstURL)
        defer { try? FileManager.default.removeItem(at: firstURL) }
        let opened = try MetadataCoreImpl().readWallpaper(at: firstURL)
        let reordered = [
            ImageAttributes(url: firstURL, index: 0, primary: false,
                            imageType: opened.attributes[0].imageType,
                            appearanceType: .light, sourceIndex: 0),
            ImageAttributes(url: firstURL, index: 1, primary: true,
                            imageType: opened.attributes[1].imageType,
                            appearanceType: .dark, sourceIndex: 1),
            ImageAttributes(url: secondURL, index: 2, primary: false,
                            imageType: .solar(altitude: 50, azimuth: 60),
                            appearanceType: nil)
        ]

        // When
        let exported = try service.createWallpaper(
            reordered, progressCallback: nil
        )
        let exportedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("heic")
        try exported.write(to: exportedURL)
        defer { try? FileManager.default.removeItem(at: exportedURL) }
        let reopened = try MetadataCoreImpl().readWallpaper(at: exportedURL)

        // Then
        XCTAssertEqual(reopened.attributes.map { $0.sourceIndex }, [0, 1, 2])
        XCTAssertEqual(
            reopened.attributes.map { $0.primary }, [true, false, false]
        )
        XCTAssertEqual(reopened.attributes[0].appearanceType, .dark)
        XCTAssertEqual(reopened.attributes[1].appearanceType, .light)
        for (index, originalIndex) in [1, 0, 1].enumerated() {
            let frame = try imageCore.extractHEICFrame(
                from: exported, at: index
            )
            XCTAssertEqual(
                HEIFMuxer.primaryCodedPayload(in: frame),
                originalPayloads[originalIndex]
            )
        }
        if case let .solar(altitude, azimuth) =
            reopened.attributes[0].imageType {
            XCTAssertEqual(altitude, 30)
            XCTAssertEqual(azimuth, 40)
        } else {
            XCTFail("Expected solar settings")
        }
    }

    func testGridFramesRemainReadableWhenCombinedAndExtracted() throws {
        // Given
        let gridURL = try XCTUnwrap(testBundle.url(
            forResource: "grid-12mp-512px-tiles", withExtension: "heic"
        ))
        let gridData = try Data(contentsOf: gridURL)
        let original = try imagePixels(gridData, index: 0)
        let attributes = [
            ImageAttributes(url: gridURL, index: 0, primary: true,
                            imageType: .appearance, appearanceType: .light),
            ImageAttributes(url: gridURL, index: 1, primary: false,
                            imageType: .appearance, appearanceType: .dark)
        ]
        let metadata = try MetadataCoreImpl().generate(from: attributes)

        // When
        let result = try imageCore.createImage(
            from: attributes, metadata: metadata, progressCallback: nil
        )
        let source = try XCTUnwrap(
            CGImageSourceCreateWithData(result as CFData, nil)
        )

        // Then
        XCTAssertEqual(CGImageSourceGetCount(source), 2)
        for index in 0..<2 {
            XCTAssertEqual(try imagePixels(result, index: index), original)
            let extracted = try imageCore.extractHEICFrame(
                from: result, at: index
            )
            XCTAssertEqual(try imagePixels(extracted, index: 0), original)
        }
    }

    func testTimeWallpaperFramesSurviveReorderAndGridAddition() throws {
        // Given
        let wallpaperURL = try XCTUnwrap(testBundle.url(
            forResource: "gradients", withExtension: "heic"
        ))
        let gridURL = try XCTUnwrap(testBundle.url(
            forResource: "grid-12mp-512px-tiles", withExtension: "heic"
        ))
        let opened = try MetadataCoreImpl().readWallpaper(at: wallpaperURL)
        XCTAssertEqual(opened.type, .time)
        XCTAssertEqual(opened.attributes.count, 9)
        let originalData = try Data(contentsOf: wallpaperURL)
        let indices = [8, 0, 4]
        let selected = indices.enumerated().map { order, index in
            let frame = opened.attributes[index]
            return ImageAttributes(
                url: wallpaperURL, index: order, primary: order == 0,
                imageType: frame.imageType, appearanceType: nil,
                sourceIndex: frame.sourceIndex
            )
        }
        let grid = ImageAttributes(
            url: gridURL, index: 3, primary: false,
            imageType: .time(date: Date()), appearanceType: nil
        )
        let attributes = selected + [grid]
        let service = WallpaperServiceImpl(
            metadataCore: MetadataCoreImpl(), imageCore: imageCore
        )

        // When
        let output = try service.createWallpaper(
            attributes, progressCallback: nil
        )
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("heic")
        try output.write(to: outputURL)
        defer { try? FileManager.default.removeItem(at: outputURL) }
        let reopened = try MetadataCoreImpl().readWallpaper(at: outputURL)

        // Then
        XCTAssertEqual(reopened.type, .time)
        XCTAssertEqual(reopened.attributes.count, 4)
        for (outputIndex, originalIndex) in indices.enumerated() {
            XCTAssertEqual(
                try imagePixels(output, index: outputIndex),
                try imagePixels(originalData, index: originalIndex)
            )
            if case let .time(date) =
                reopened.attributes[outputIndex].imageType,
               case let .time(expected) = selected[outputIndex].imageType {
                XCTAssertEqual(
                    date.timeIntervalSince(expected), 0, accuracy: 1
                )
            } else {
                XCTFail("Expected time settings")
            }
        }
        XCTAssertEqual(
            try imagePixels(output, index: 3),
            try imagePixels(Data(contentsOf: gridURL), index: 0)
        )
        for index in 0..<4 {
            let extracted = try imageCore.extractHEICFrame(
                from: output, at: index
            )
            XCTAssertEqual(
                try imagePixels(extracted, index: 0),
                try imagePixels(output, index: index)
            )
        }

        let reordered = [3, 1, 0].enumerated().map { order, index in
            let frame = reopened.attributes[index]
            return ImageAttributes(
                url: outputURL, index: order, primary: order == 0,
                imageType: frame.imageType, appearanceType: nil,
                sourceIndex: frame.sourceIndex
            )
        }
        let repacked = try service.createWallpaper(
            reordered, progressCallback: nil
        )
        for (index, originalIndex) in [3, 1, 0].enumerated() {
            XCTAssertEqual(
                try imagePixels(repacked, index: index),
                try imagePixels(output, index: originalIndex)
            )
            let extracted = try imageCore.extractHEICFrame(
                from: repacked, at: index
            )
            XCTAssertEqual(
                try imagePixels(extracted, index: 0),
                try imagePixels(output, index: originalIndex)
            )
        }
    }

    private func imagePixels(_ data: Data, index: Int) throws -> Data {
        let source = try XCTUnwrap(
            CGImageSourceCreateWithData(data as CFData, nil)
        )
        let image = try XCTUnwrap(CGImageSourceCreateImageAtIndex(
            source, index, nil
        ))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = try XCTUnwrap(CGContext(
            data: nil, width: 32, height: 32, bitsPerComponent: 8,
            bytesPerRow: 32 * 4, space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.draw(image, in: CGRect(x: 0, y: 0, width: 32, height: 32))
        let pixels = try XCTUnwrap(context.data)
        return Data(bytes: pixels, count: 32 * 32 * 4)
    }

    func testGetImageFormat() throws {
        // Given
        // swiftlint:disable:next force_unwrapping
        let path = testBundle.path(forResource: "image", ofType: "heic")!
        let url = URL(fileURLWithPath: path)
        let result = ImageFormatType.heic
        
        // When
        let format = try imageCore.getImageFormat(for: url)
        
        // Then
        XCTAssertEqual(format, result)
    }

    func testGetImageFormatWithMIF1Brand() throws {
        // Given
        // swiftlint:disable:next force_unwrapping
        let path = testBundle.path(forResource: "image", ofType: "heic")!
        var data = try Data(contentsOf: URL(fileURLWithPath: path))
        data.replaceSubrange(8..<12, with: Data("mif1".utf8))

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("heic")
        try data.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        // When
        let format = try imageCore.getImageFormat(for: url)

        // Then
        XCTAssertEqual(format, .heic)
    }
    
    func testValidateImage() throws {
        // Given
        // swiftlint:disable:next force_unwrapping
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
