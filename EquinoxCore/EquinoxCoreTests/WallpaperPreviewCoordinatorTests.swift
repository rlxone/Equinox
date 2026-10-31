import EquinoxCore
import XCTest

private final class PreviewTestService: WallpaperService {
	var result: Result<Data, Error> = .success(Data([1, 2, 3]))
	var requests: [[ImageAttributes]] = []

	func createWallpaper(
		_ attributes: [ImageAttributes], settings: ImageExportSettings,
		progressCallback: ProgressCallback?
	) throws -> Data {
		requests.append(attributes)
		return try result.get()
	}
}

class WallpaperPreviewCoordinatorTests: XCTestCase {
	private var service: PreviewTestService!
	private var scheduled: [() -> Void] = []
	private var work: [() -> Void] = []
	private var coordinator: WallpaperPreviewCoordinator!
	private let url = URL(fileURLWithPath: "/image.heic")

	override func setUp() {
		super.setUp()
		service = PreviewTestService()
		coordinator = WallpaperPreviewCoordinator(
			service: service,
			schedule: { [weak self] _, action in self?.scheduled.append(action) },
			execute: { [weak self] action in self?.work.append(action) }
		)
	}

	override func tearDown() {
		coordinator = nil
		scheduled = []
		work = []
		service = nil
		super.tearDown()
	}

	func testOnlyLatestScheduledRequestIsExecuted() {
		coordinator.update([attribute(altitude: 1)], settings: .default)
		coordinator.update([attribute(sourceIndex: 1)], settings: .default)
		scheduled.forEach { $0() }

		XCTAssertEqual(work.count, 1)
		work[0]()
		XCTAssertEqual(service.requests.count, 1)
		XCTAssertEqual(service.requests[0][0].sourceIndex, 1)
	}

	func testOutdatedResultCannotReplaceNewerPreview() throws {
		let ready = expectation(description: "Latest preview is ready")
		let drained = expectation(description: "Both results processed")
		var readyCount = 0
		coordinator.stateDidChange = { state in
			if case .ready = state {
				readyCount += 1
				ready.fulfill()
			}
		}
		coordinator.update([attribute(altitude: 1)], settings: .default)
		scheduled.removeFirst()()
		coordinator.update([attribute(sourceIndex: 1)], settings: .default)
		scheduled.removeFirst()()

		work[1]()
		work[0]()
		DispatchQueue.main.async { drained.fulfill() }
		wait(for: [ready, drained], timeout: 2)
		let url = try XCTUnwrap(coordinator.previewURL)
		XCTAssertEqual(try Data(contentsOf: url), Data([1, 2, 3]))
		XCTAssertEqual(readyCount, 1)
		coordinator.update([], settings: .default)
		XCTAssertNil(coordinator.previewURL)
		XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
	}

	func testFailedAndEmptyRequestsReportTheirState() {
		let failed = expectation(description: "Preview failed")
		var empty = false
		coordinator.stateDidChange = { state in
			switch state {
			case .failed: failed.fulfill()
			case .empty: empty = true
			default: break
			}
		}
		service.result = .failure(CocoaError(.fileReadUnknown))
		coordinator.update([attribute()], settings: .default)
		scheduled.removeFirst()()
		work.removeFirst()()
		wait(for: [failed], timeout: 2)
		coordinator.update([], settings: .default)

		XCTAssertTrue(empty)
		XCTAssertNil(coordinator.previewURL)
	}

	func testChangesToImageAndExportSettingsScheduleNewPreview() {
		let first = attribute()
		coordinator.update([first], settings: .default)
		coordinator.update([first], settings: .default)
		XCTAssertEqual(scheduled.count, 1)
		coordinator.update([attribute(altitude: 2)], settings: .default)
		coordinator.update([attribute(azimuth: 2)], settings: .default)
		coordinator.update([first], settings: ImageExportSettings(
			lossyCompressionScope: .allImages, imageQuality: 50
		))
		coordinator.update([first], settings: ImageExportSettings(
			lossyCompressionScope: .allImages, imageQuality: 60
		))
		XCTAssertEqual(scheduled.count, 3)
	}

	func testChangingTimeAndOrderInvalidatesPreview() throws {
		let date = Date(timeIntervalSince1970: 1000)
		func timed(_ offset: TimeInterval, index: Int) -> ImageAttributes {
			return ImageAttributes(
				url: url, index: index, primary: index == 0,
				imageType: .time(date: date.addingTimeInterval(offset)),
				appearanceType: nil, sourceIndex: index
			)
		}
		let first = timed(0, index: 0)
		let second = timed(60, index: 1)
		let ready = expectation(description: "Size is ready")
		coordinator.stateDidChange = { state in
			if case .ready = state { ready.fulfill() }
		}
		coordinator.update([first, second], settings: .default)
		coordinator.update([second, first], settings: .default)
		coordinator.update([first, timed(120, index: 1)], settings: .default)

		XCTAssertEqual(scheduled.count, 1)
		scheduled.removeFirst()()
		work.removeFirst()()
		wait(for: [ready], timeout: 2)
		XCTAssertNil(coordinator.previewURL)
		coordinator.update([first, second], settings: .default)
		XCTAssertNotNil(coordinator.previewURL)
	}

	func testDeinitRemovesPreviewFile() throws {
		let ready = expectation(description: "Preview ready")
		coordinator.stateDidChange = { state in
			if case .ready = state { ready.fulfill() }
		}
		coordinator.update([attribute()], settings: .default)
		scheduled.removeFirst()()
		work.removeFirst()()
		wait(for: [ready], timeout: 2)
		let url = try XCTUnwrap(coordinator.previewURL)
		XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

		coordinator = nil
		XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
	}

	private func attribute(
		altitude: Double = 0, azimuth: Double = 0, sourceIndex: Int? = nil
	) -> ImageAttributes {
		return ImageAttributes(
			url: url, index: 0, primary: true,
			imageType: .solar(altitude: altitude, azimuth: azimuth),
			appearanceType: .light, sourceIndex: sourceIndex
		)
	}
}
