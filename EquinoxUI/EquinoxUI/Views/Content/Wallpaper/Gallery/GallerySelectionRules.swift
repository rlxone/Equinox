import Foundation

public enum GallerySelectionRules {
	public static func setAppearance(
		_ selected: AppearanceType, for model: GalleryModel,
		in items: [GalleryModel]
	) -> [GalleryModel] {
		let addsLight = model.appearance != .light
			&& model.appearance != .both
			&& (selected == .light || selected == .both)
		let addsDark = model.appearance != .dark
			&& model.appearance != .both
			&& (selected == .dark || selected == .both)
		var changed: [GalleryModel] = []
		for other in items where other !== model {
			let light = (other.appearance == .light
				|| other.appearance == .both) && !addsLight
			let dark = (other.appearance == .dark
				|| other.appearance == .both) && !addsDark
			let updated: AppearanceType
			switch (light, dark) {
			case (false, false): updated = .all
			case (true, false): updated = .light
			case (false, true): updated = .dark
			case (true, true): updated = .both
			}
			if other.appearance != updated {
				other.appearance = updated
				changed.append(other)
			}
		}
		model.appearance = selected
		changed.append(model)
		return changed
	}

	public static func setPrimary(
		_ model: GalleryModel, in items: [GalleryModel]
	) -> [GalleryModel] {
		var changed: [GalleryModel] = []
		for item in items where item !== model && item.primary {
			item.primary = false
			changed.append(item)
		}
		model.primary = true
		changed.append(model)
		return changed
	}
}
