import EquinoxCore
import XCTest

class WallpaperEditingStateTests: XCTestCase {
	private let url = URL(fileURLWithPath: "/image.heic")

	func testNewWallpaperBecomesDirtyWhenImagesAreAdded() {
		let state = WallpaperEditingState(savedAttributes: nil)

		XCTAssertFalse(state.hasUnsavedChanges(current: [], hasItems: false))
		XCTAssertTrue(state.hasUnsavedChanges(
			current: [attribute()], hasItems: true
		))
		XCTAssertFalse(state.canRevert(current: [attribute()]))
	}

	func testSaveAndRevertUseMostRecentlySavedAttributes() throws {
		var state = WallpaperEditingState(savedAttributes: [attribute()])
		let edited = [attribute(appearance: .dark)]

		XCTAssertFalse(state.canRevert(current: [attribute()]))
		XCTAssertTrue(state.hasUnsavedChanges(current: edited, hasItems: true))
		XCTAssertEqual(state.savedAttributes?.first?.appearanceType, .light)
		state.markSaved(edited)
		XCTAssertFalse(state.hasUnsavedChanges(current: edited, hasItems: true))
		XCTAssertTrue(state.canRevert(current: [attribute()]))
		let restored = try XCTUnwrap(state.savedAttributes)
		XCTAssertEqual(restored.first?.appearanceType, .dark)
		XCTAssertFalse(state.canRevert(current: restored))
	}

	func testChangingImagePropertiesOrOrderRequiresRevert() {
		let initial = [attribute(), attribute(sourceIndex: 1)]
		let state = WallpaperEditingState(savedAttributes: initial)
		let changes = [
			[attribute(url: URL(fileURLWithPath: "/other.heic")), initial[1]],
			[attribute(sourceIndex: 2), initial[1]],
			[attribute(primary: false), initial[1]],
			[attribute(appearance: .dark), initial[1]],
			[initial[1], initial[0]],
			[initial[0]],
			initial + [attribute()]
		]

		for current in changes {
			XCTAssertTrue(state.canRevert(current: current))
		}
		XCTAssertTrue(state.canRevert(current: nil))
		XCTAssertFalse(state.canRevert(current: initial))
	}

	func testChangingSolarTimeOrWallpaperTypeRequiresRevert() {
		let solar = attribute(type: .solar(altitude: 10, azimuth: 20))
		let date = Date(timeIntervalSince1970: 1000)
		let time = attribute(type: .time(date: date))
		let solarState = WallpaperEditingState(savedAttributes: [solar])
		let timeState = WallpaperEditingState(savedAttributes: [time])

		XCTAssertFalse(solarState.canRevert(current: [solar]))
		XCTAssertTrue(solarState.canRevert(current: [attribute(
			type: .solar(altitude: 11, azimuth: 20)
		)]))
		XCTAssertTrue(solarState.canRevert(current: [attribute(
			type: .solar(altitude: 10, azimuth: 21)
		)]))
		XCTAssertTrue(solarState.canRevert(current: [time]))
		XCTAssertFalse(timeState.canRevert(current: [time]))
		XCTAssertTrue(timeState.canRevert(current: [attribute(
			type: .time(date: date.addingTimeInterval(60))
		)]))
	}

	func testDecodeSolarDragArchive() throws {
		let data = try NSKeyedArchiver.archivedData(
			withRootObject: ["123.5", "-45.25"],
			requiringSecureCoding: false
		)
		let values = try XCTUnwrap(SolarDragValues(data: data))

		XCTAssertEqual(values.azimuth, "123.5")
		XCTAssertEqual(values.altitude, "-45.25")
	}

	func testRejectEmptyAndWrongTypeSolarDragArchives() throws {
		let empty = try NSKeyedArchiver.archivedData(
			withRootObject: [String](), requiringSecureCoding: false
		)
		let wrongType = try NSKeyedArchiver.archivedData(
			withRootObject: "123", requiringSecureCoding: false
		)

		XCTAssertNil(SolarDragValues(data: empty))
		XCTAssertNil(SolarDragValues(data: wrongType))
	}

	func testSuccessfulSaveMarksCurrentStateAsSaved() throws {
		let destination = FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
		defer { try? FileManager.default.removeItem(at: destination) }
		let data = Data([1, 2, 3])
		let edited = [attribute(appearance: .dark)]
		var state = WallpaperEditingState(savedAttributes: [attribute()])

		try WallpaperFileSaver().save(data, to: destination) {
			state.markSaved(edited)
		}

		XCTAssertEqual(try Data(contentsOf: destination), data)
		XCTAssertFalse(state.hasUnsavedChanges(current: edited, hasItems: true))
	}

	func testFailedSaveDoesNotMarkCurrentStateAsSaved() {
		let directory = FileManager.default.temporaryDirectory
			.appendingPathComponent(UUID().uuidString)
		let destination = directory.appendingPathComponent("wallpaper.heic")
		let edited = [attribute(appearance: .dark)]
		var state = WallpaperEditingState(savedAttributes: [attribute()])

		XCTAssertThrowsError(try WallpaperFileSaver().save(
			Data([1]), to: destination
		) {
			state.markSaved(edited)
		})
		XCTAssertTrue(state.hasUnsavedChanges(current: edited, hasItems: true))
	}

	private func attribute(
		url: URL? = nil, primary: Bool = true,
		type: ImageType = .appearance,
		appearance: EquinoxCore.AppearanceType? = .light,
		sourceIndex: Int? = 0
	) -> ImageAttributes {
		return ImageAttributes(
			url: url ?? self.url, index: 0, primary: primary,
			imageType: type, appearanceType: appearance,
			sourceIndex: sourceIndex
		)
	}
}
