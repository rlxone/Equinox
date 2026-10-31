import Foundation

struct WallpaperFileSaver {
	func save(_ data: Data, to url: URL, didSave: () -> Void) throws {
		try data.write(to: url, options: .atomic)
		didSave()
	}
}
