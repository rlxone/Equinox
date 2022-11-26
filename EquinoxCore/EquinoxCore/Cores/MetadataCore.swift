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

import Foundation
import ImageIO

// MARK: - Protocols

public protocol MetadataCore {
    func generate(from attributes: [ImageAttributes]) throws -> CGImageMetadata
    func getImageMetadata(for url: URL) throws -> ExifMetadata
}

// MARK: - Enums, Structs

extension MetadataCoreImpl {
    private enum MetadataTag: String, CaseIterable {
        case latitude
        case longitude
        case date
    }
}

// MARK: - Class

public final class MetadataCoreImpl: MetadataCore {
    public init() {
    }
    
    // MARK: - Public

    public func generate(from attributes: [ImageAttributes]) throws -> CGImageMetadata {
        let metadata = CGImageMetadataCreateMutable()
        let imageMetadata = try createImageMetadata(attributes)
        let imageMetadataType = try getImageMetadataType(imageMetadata)
        let encodedImageMetadata = try encodeImageMetadata(imageMetadata, type: imageMetadataType)
        try setupImageMetadata(metadata: metadata, encodedValue: encodedImageMetadata, type: imageMetadataType)
        return metadata
    }

    public func getImageMetadata(for url: URL) throws -> ExifMetadata {
        guard
            let source = CGImageSourceCreateWithURL(url as CFURL, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
        else {
            throw MetadataError.wrongMetadataType
        }
        
        var latitude: Double?
        var longitude: Double?
        var date: Date?
        var timezone: TimeZone?
        
        let exifDictionary = properties[kCGImagePropertyExifDictionary as String] as? [String: Any]
        let gpsDictionary = properties[kCGImagePropertyGPSDictionary as String] as? [String: Any]
        
        if let gpsDictionary = gpsDictionary {
            let coordinate = getCoordinate(from: gpsDictionary)
            latitude = coordinate.latitude
            longitude = coordinate.longitude
        }
        
        if let exifDictionary = exifDictionary {
            date = getDate(from: exifDictionary)
            timezone = getTimezone(from: exifDictionary)
        }
        
        return ExifMetadata(
            latitude: latitude,
            longitude: longitude,
            createDate: date,
            timezone: timezone
        )
    }
    
    // MARK: - Private

    private func createImageMetadata(_ attributes: [ImageAttributes]) throws -> ImageMetadata {
        var solarMetadata: [SolarMetadata]?
        var timeMetadata: [TimeMetadata]?
        var appearanceMetadata: ApperanceMetadata?

        for attribute in attributes {
            switch attribute.imageType {
            case .solar(let altitude, let azimuth):
                if solarMetadata == nil {
                    solarMetadata = []
                }
                let metadata = SolarMetadata(index: attribute.index, altitude: altitude, azimuth: azimuth)
                solarMetadata?.append(metadata)

            case .time(let date):
                if timeMetadata == nil {
                    timeMetadata = []
                }
                let dayPercentage = getDayPercentage(from: date)
                let metadata = TimeMetadata(index: attribute.index, time: dayPercentage)
                timeMetadata?.append(metadata)

            case .appearance:
                break
            }

            if let appearanceType = attribute.appearanceType {
                if appearanceMetadata == nil {
                    appearanceMetadata = ApperanceMetadata(lightIndex: 0, darkIndex: 0)
                }
                switch appearanceType {
                case .light:
                    appearanceMetadata?.lightIndex = attribute.index

                case .dark:
                    appearanceMetadata?.darkIndex = attribute.index
                }
            }
        }

        return ImageMetadata(
            solarMetadata: solarMetadata,
            timeMetadata: timeMetadata,
            appearanceMetadata: appearanceMetadata
        )
    }

    private func encodeImageMetadata(_ metadata: ImageMetadata, type: ImageMetadataType) throws -> String {
        let encoder = PropertyListEncoder()

        switch type {
        case .solar, .time:
            return try encoder.encode(metadata).base64EncodedString()

        case .appearance:
            return try encoder.encode(metadata.appearanceMetadata).base64EncodedString()
        }
    }

    private func setupImageMetadata(metadata: CGMutableImageMetadata, encodedValue: String, type: ImageMetadataType) throws {
        let xmlns = "http://ns.apple.com/namespace/1.0/" as CFString
        let prefix = "apple_desktop" as CFString
        let key = type.rawValue as CFString
        let path = "\(prefix):\(key)" as CFString
        let value = encodedValue as CFTypeRef

        guard CGImageMetadataRegisterNamespaceForPrefix(metadata, xmlns, prefix, nil) else {
            throw MetadataError.namespaceNotRegistered
        }

        guard let tag = CGImageMetadataTagCreate(xmlns, prefix, key, .string, value) else {
            throw MetadataError.tagNotCreated
        }

        guard CGImageMetadataSetTagWithPath(metadata, nil, path, tag) else {
            throw MetadataError.tagNotSet
        }
    }

    private func getImageMetadataType(_ metadata: ImageMetadata) throws -> ImageMetadataType {
        if metadata.solarMetadata != nil {
            return .solar
        }
        if metadata.timeMetadata != nil {
            return .time
        }
        if metadata.appearanceMetadata != nil {
            return .appearance
        }
        throw MetadataError.wrongMetadataType
    }

    private func getDayPercentage(from date: Date) -> Double {
        let calendar = getCurrentCalendar
        let startOfDay = calendar.startOfDay(for: date)
        let seconds = calendar.dateComponents([.second], from: startOfDay, to: date).second ?? 0
        let oneDaySeconds = 24 * 60 * 60
        let percentage = Double(seconds) / Double(oneDaySeconds)
        return percentage
    }
    
    private func getCoordinate(from exifData: [String: Any]) -> (latitude: Double?, longitude: Double?) {
        let latitude = exifData[kCGImagePropertyGPSLatitude as String] as? Double
        let longitude = exifData[kCGImagePropertyGPSLongitude as String] as? Double
        
        return (latitude, longitude)
    }
    
    private func getDate(from exifData: [String: Any]) -> Date? {
        let dateString = exifData[kCGImagePropertyExifDateTimeOriginal as String] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        var date: Date?
        if let dateString = dateString {
            date = dateFormatter.date(from: dateString)
        }
        
        return date
    }
    
    private func getTimezone(from exifData: [String: Any]) -> TimeZone? {
        var timeOffset: String?
        
        if #available(macOS 10.15, *) {
            timeOffset = exifData[kCGImagePropertyExifOffsetTimeOriginal as String] as? String
        }
        
        var timezone: TimeZone?
        if let timeOffset = timeOffset {
            timezone = TimeZone(abbreviation: "GMT\(timeOffset)")
        }
        
        return timezone
    }
}
