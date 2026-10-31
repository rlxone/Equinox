import XCTest

class GalleryDragOperationsTests: XCTestCase {
	func testMoveMiddleImageToEitherEnd() {
		let items = ["left", "middle", "right"]

		XCTAssertEqual(
			GalleryDragOperations.moved(items, indices: [1], destination: 0),
			["middle", "left", "right"]
		)
		XCTAssertEqual(
			GalleryDragOperations.moved(items, indices: [1], destination: 3),
			["left", "right", "middle"]
		)
	}

	func testMoveMultipleImagesPreservesTheirOriginalOrder() {
		let result = GalleryDragOperations.moved(
			[0, 1, 2, 3, 4], indices: [3, 1], destination: 5
		)

		XCTAssertEqual(result, [0, 2, 4, 1, 3])
	}

	func testMoveRejectsInvalidIndicesAndDestination() {
		XCTAssertNil(GalleryDragOperations.moved(
			[0, 1], indices: [1, 1], destination: 0
		))
		XCTAssertNil(GalleryDragOperations.moved(
			[0, 1], indices: [2], destination: 0
		))
		XCTAssertNil(GalleryDragOperations.moved(
			[0, 1], indices: [0], destination: 3
		))
	}

	func testDragSessionDoesNotReuseAnEarlierSelection() {
		var session = GalleryDragSession()
		let first = IndexPath(item: 0, section: 0)
		let second = IndexPath(item: 1, section: 0)
		session.begin(at: [first, second])
		session.end()
		XCTAssertTrue(session.indexPaths.isEmpty)

		session.begin(at: [second])
		XCTAssertEqual(session.indexPaths, [second])
	}

	func testCopyPreservesSettingsWithoutSharingMutableState() throws {
		let date = Date(timeIntervalSince1970: 1234)
		let model = GalleryModel(
			number: 2, url: URL(fileURLWithPath: "/image.heic"),
			appearance: .dark, primary: true, azimuth: 12,
			altitude: 34, time: date, sourceIndex: 3
		)
		let copy = try XCTUnwrap(
			GalleryDragOperations.copies([model], indices: [0]).first
		)

		XCTAssertFalse(copy === model)
		XCTAssertEqual(copy.url, model.url)
		XCTAssertEqual(copy.sourceIndex, 3)
		XCTAssertEqual(copy.appearance, .all)
		XCTAssertFalse(copy.primary)
		XCTAssertEqual(model.appearance, .dark)
		XCTAssertTrue(model.primary)
		XCTAssertEqual(copy.azimuth, 12)
		XCTAssertEqual(copy.altitude, 34)
		XCTAssertEqual(copy.time, date)
		copy.azimuth = 99
		XCTAssertEqual(model.azimuth, 12)
	}

	func testCopyRespectsLimitAndSelectionOrder() {
		let models = (0..<3).map { index in
			GalleryModel(
				number: index + 1, url: URL(fileURLWithPath: "/\(index)"),
				appearance: .all, primary: false, azimuth: nil,
				altitude: nil, time: nil
			)
		}
		let copies = GalleryDragOperations.copies(
			models, indices: [2, 0], limit: 1
		)

		XCTAssertEqual(copies.map { $0.url }, [models[0].url])
		XCTAssertTrue(GalleryDragOperations.copies(
			models, indices: [0], limit: 0
		).isEmpty)

		let marked = [AppearanceType.light, .dark, .both, .all].map {
			model(1, appearance: $0, primary: true)
		}
		let unmarked = GalleryDragOperations.copies(
			marked, indices: Array(marked.indices)
		)
		XCTAssertEqual(unmarked.map { $0.appearance },
			[.all, .all, .all, .all])
		XCTAssertTrue(unmarked.allSatisfy { !$0.primary })
		XCTAssertEqual(marked.map { $0.appearance },
			[.light, .dark, .both, .all])
		XCTAssertTrue(marked.allSatisfy { $0.primary })
	}

	func testCopyInsertionOnEitherSideOfMiddleImage() throws {
		let frames = (0..<3).map {
			NSRect(x: $0 * 120, y: 0, width: 100, height: 100)
		}
		let before = try XCTUnwrap(GalleryDragOperations.insertion(
			at: NSPoint(x: 140, y: 50), frames: frames
		))
		let after = try XCTUnwrap(GalleryDragOperations.insertion(
			at: NSPoint(x: 200, y: 50), frames: frames
		))

		XCTAssertEqual(before.index, 1)
		XCTAssertEqual(before.marker.midX, 110)
		XCTAssertEqual(after.index, 2)
		XCTAssertEqual(after.marker.midX, 230)
	}

	func testCopyInsertionHandlesRowEdgesAndEmptyGallery() throws {
		let frames = [
			NSRect(x: 0, y: 0, width: 100, height: 100),
			NSRect(x: 120, y: 0, width: 100, height: 100),
			NSRect(x: 0, y: 120, width: 100, height: 100)
		]
		let result = try XCTUnwrap(GalleryDragOperations.insertion(
			at: NSPoint(x: 10, y: 150), frames: frames
		))

		XCTAssertEqual(result.index, 2)
		XCTAssertEqual(result.marker.midX, -10)
		XCTAssertNil(GalleryDragOperations.insertion(at: .zero, frames: []))
	}

	func testAssigningLightPreservesOtherImagesDarkAppearance() {
		let first = model(1, appearance: .both, primary: true)
		let second = model(2, appearance: .all, primary: false)
		let changed = GallerySelectionRules.setAppearance(
			.light, for: second, in: [first, second]
		)

		XCTAssertEqual(first.appearance, .dark)
		XCTAssertEqual(second.appearance, .light)
		XCTAssertEqual(changed.count, 2)
	}

	func testAssigningBothClearsOtherAppearances() {
		let first = model(1, appearance: .light, primary: true)
		let second = model(2, appearance: .dark, primary: false)
		let third = model(3, appearance: .all, primary: false)
		_ = GallerySelectionRules.setAppearance(
			.both, for: third, in: [first, second, third]
		)

		XCTAssertEqual(first.appearance, .all)
		XCTAssertEqual(second.appearance, .all)
		XCTAssertEqual(third.appearance, .both)
	}

	func testAssigningPrimaryClearsPreviousPrimary() {
		let first = model(1, appearance: .light, primary: true)
		let second = model(2, appearance: .dark, primary: false)
		let changed = GallerySelectionRules.setPrimary(
			second, in: [first, second]
		)

		XCTAssertFalse(first.primary)
		XCTAssertTrue(second.primary)
		XCTAssertEqual(changed.count, 2)
	}

	private func model(
		_ number: Int, appearance: AppearanceType, primary: Bool
	) -> GalleryModel {
		return GalleryModel(
			number: number, url: URL(fileURLWithPath: "/image"),
			appearance: appearance, primary: primary,
			azimuth: nil, altitude: nil, time: nil
		)
	}

}
