import Foundation

struct SolarDragValues {
	let azimuth: String
	let altitude: String

	init?(data: Data) {
		guard let archive = try? NSKeyedUnarchiver.unarchivedObject(
			ofClasses: [NSArray.self, NSString.self], from: data
		), let values = archive as? [String],
			let azimuth = values.first, let altitude = values.last else {
			return nil
		}
		self.azimuth = azimuth
		self.altitude = altitude
	}
}
