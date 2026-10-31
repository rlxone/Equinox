import EquinoxCore
import Foundation

struct WallpaperEditingState {
	private(set) var savedAttributes: [ImageAttributes]?

	init(savedAttributes: [ImageAttributes]?) {
		self.savedAttributes = savedAttributes
	}

	mutating func markSaved(_ attributes: [ImageAttributes]?) {
		savedAttributes = attributes
	}

	func canRevert(current: [ImageAttributes]?) -> Bool {
		guard let saved = savedAttributes else { return false }
		guard let current = current, saved.count == current.count else {
			return true
		}
		for (original, edited) in zip(saved, current) {
			if original.url != edited.url
				|| original.sourceIndex != edited.sourceIndex
				|| original.primary != edited.primary
				|| original.appearanceType != edited.appearanceType {
				return true
			}
			switch (original.imageType, edited.imageType) {
			case let (.solar(a, z), .solar(b, y)):
				if a != b || z != y { return true }
			case let (.time(a), .time(b)):
				if a != b { return true }
			case (.appearance, .appearance):
				break
			default:
				return true
			}
		}
		return false
	}

	func hasUnsavedChanges(
		current: [ImageAttributes]?, hasItems: Bool
	) -> Bool {
		guard savedAttributes != nil else { return hasItems }
		return canRevert(current: current)
	}
}

