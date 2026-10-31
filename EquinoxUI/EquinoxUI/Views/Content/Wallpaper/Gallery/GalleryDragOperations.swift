import AppKit

public enum GalleryDragOperations {
	public static func moved<T>(
		_ items: [T], indices: [Int], destination: Int
	) -> [T]? {
		let indices = indices.sorted()
		guard !indices.isEmpty, Set(indices).count == indices.count,
			indices.allSatisfy({ items.indices.contains($0) }),
			(0...items.count).contains(destination)
		else { return nil }
		let selected = indices.map { items[$0] }
		let shift = indices.filter { $0 < destination }.count
		var result = items
		for index in indices.reversed() { result.remove(at: index) }
		result.insert(contentsOf: selected, at: destination - shift)
		return result
	}

	public static func copies(
		_ items: [GalleryModel], indices: [Int], limit: Int? = nil
	) -> [GalleryModel] {
		let count = max(0, limit ?? indices.count)
		return indices.sorted().prefix(count).compactMap { index in
			guard items.indices.contains(index) else { return nil }
			let item = items[index]
			return GalleryModel(
				number: item.number, url: item.url,
				appearance: .all, primary: false,
				azimuth: item.azimuth, altitude: item.altitude,
				time: item.time, sourceIndex: item.sourceIndex
			)
		}
	}

	public static func insertion(
		at point: NSPoint, frames: [NSRect]
	) -> (target: Int, index: Int, marker: NSRect)? {
		guard let nearest = frames.indices.min(by: { first, second in
			func distance(_ frame: NSRect) -> CGFloat {
				let dx = max(frame.minX - point.x, 0, point.x - frame.maxX)
				let dy = max(frame.minY - point.y, 0, point.y - frame.maxY)
				return dx * dx + dy * dy
			}
			return distance(frames[first]) < distance(frames[second])
		}) else { return nil }
		let frame = frames[nearest]
		let after = point.x >= frame.midX
		let neighbor = after ? nearest + 1 : nearest - 1
		var x = after ? frame.maxX + 10 : frame.minX - 10
		if frames.indices.contains(neighbor) {
			let other = frames[neighbor]
			if abs(other.midY - frame.midY) < 1 {
				x = after ? (frame.maxX + other.minX) / 2
					: (other.maxX + frame.minX) / 2
			}
		}
		return (
			nearest, nearest + (after ? 1 : 0),
			NSRect(x: x - 5, y: frame.minY, width: 10, height: frame.height)
		)
	}
}

public struct GalleryDragSession {
	public private(set) var indexPaths: [IndexPath] = []

	public init() {
	}

	public mutating func begin(at indexPaths: Set<IndexPath>) {
		self.indexPaths = indexPaths.sorted()
	}

	public mutating func end() {
		indexPaths = []
	}
}
