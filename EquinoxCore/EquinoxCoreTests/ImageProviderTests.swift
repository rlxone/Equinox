import AppKit
import EquinoxCore
import XCTest

class ImageProviderTests: XCTestCase {
	private var service: ImageServiceImpl!
	private var provider: ImageProviderImpl!
	private lazy var testBundle = Bundle(for: type(of: self))

	override func setUp() {
		super.setUp()
		service = ImageServiceImpl(
			metadataCore: MetadataCoreImpl(), imageCore: ImageCoreImpl(),
			imageCacheCore: ImageCacheCoreImpl(totalCostLimit: 10_000_000)
		)
		provider = ImageProviderImpl(imageService: service)
	}

	func testIndexedHEICDoesNotReturnCachedWholeImage() throws {
		let url = try XCTUnwrap(testBundle.url(
			forResource: "image", withExtension: "heic"
		))
		let cached = NSImage(size: NSSize(width: 2, height: 2))
		service.cacheImage(url: url, image: cached)
		let loaded = expectation(description: "HEIC frame loaded")

		provider.loadImage(
			url: url, sourceIndex: 0,
			resizeMode: .resized(
				size: NSSize(width: 80, height: 80), respectAspect: true
			)
		) { image in
			XCTAssertNotNil(image)
			XCTAssertFalse(image === cached)
			loaded.fulfill()
		}
		wait(for: [loaded], timeout: 5)
	}

	func testInvalidHEICFrameCompletesWithNoImage() throws {
		let url = try XCTUnwrap(testBundle.url(
			forResource: "image", withExtension: "heic"
		))
		let loaded = expectation(description: "Invalid frame rejected")

		provider.loadImage(url: url, sourceIndex: 9999, resizeMode: .source) {
			image in
			XCTAssertNil(image)
			loaded.fulfill()
		}
		wait(for: [loaded], timeout: 5)
	}

	func testWholeImageUsesExistingCache() throws {
		let url = try XCTUnwrap(testBundle.url(
			forResource: "image", withExtension: "png"
		))
		let cached = NSImage(size: NSSize(width: 2, height: 2))
		service.cacheImage(url: url, image: cached)
		let loaded = expectation(description: "Cached image loaded")

		provider.loadImage(url: url, sourceIndex: nil, resizeMode: .source) {
			image in
			XCTAssertTrue(image === cached)
			loaded.fulfill()
		}
		wait(for: [loaded], timeout: 5)
	}
}
