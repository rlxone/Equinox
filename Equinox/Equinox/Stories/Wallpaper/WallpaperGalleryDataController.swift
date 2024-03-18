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

import AppKit
import EquinoxAssets
import EquinoxCore
import EquinoxUI

extension WallpaperGalleryDataController {
    private enum Constants {
        static let oneDaySeconds = 24 * 60 * 60
    }
}

final class WallpaperGalleryDataController {
    private let type: WallpaperType
    private let fileService: FileService
    private let solarService: SolarService
    private let imageProvider: ImageProvider
    
    private var mutableData = GalleryData(items: [], info: String())
    private var filesizeCache: [URL: UInt64] = [:]
    
    // MARK: - Initializer
    
    init(type: WallpaperType, fileService: FileService, solarService: SolarService, imageProvider: ImageProvider) {
        self.type = type
        self.fileService = fileService
        self.solarService = solarService
        self.imageProvider = imageProvider
    }
    
    // MARK: - Public
    
    var data: GalleryData {
        return mutableData
    }
    
    func refreshData() {
        var containsPrimary = false
        var totalSize: UInt64 = 0
        
        for (index, model) in mutableData.items.enumerated() {
            if model.primary {
                containsPrimary = true
            }
            model.number = index + 1
            if let filesize = filesizeCache[model.url] {
                totalSize += filesize
            } else {
                totalSize += calculateFilesize(model.url) ?? 0
            }
        }
        
        if !containsPrimary {
            mutableData.items.first?.primary = true
        }
        
        switch type {
        case .appearance:
            refreshAppearanceData()
            
        case .solar, .time:
            break
        }
        
        refreshInfo(totalSize: totalSize)
    }
    
    func make(_ urls: [URL], insertIndexPath: IndexPath) -> [(indexPath: IndexPath, model: GalleryModel)] {
        let calendar = getCurrentCalendar
        let startTime = calendar.startOfDay(for: Date())
        var newData: [(IndexPath, GalleryModel)] = []
        let oneDaySeconds = 24 * 60 * 60
        let oneImageInterval = oneDaySeconds / urls.count
        
        for (index, url) in urls.enumerated() {
            let newIndex = insertIndexPath.item + index
            let indexPath = IndexPath(item: newIndex, section: insertIndexPath.section)
            let count = data.items.count + index
            
            let isPrimary = isPrimaryIndex(count)
            let imageData = calculateImageData(url)
            let addingInterval = data.items.isEmpty ? oneImageInterval * index : 0
            let time = calendar.date(byAdding: .second, value: addingInterval, to: startTime)
            
            let model = GalleryModel(
                number: newIndex + 1,
                url: url,
                appearance: .all,
                primary: isPrimary,
                azimuth: imageData?.azimuth,
                altitude: imageData?.altitude,
                time: time
            )
            
            newData.append((indexPath, model))
        }
        
        return newData
    }
    
    func insert(_ items: [GalleryModel], at index: Int) {
        mutableData.items.insert(contentsOf: items, at: index)
    }
    
    func remove(at index: Int) {
        mutableData.items.remove(at: index)
    }
    
    // MARK: - Private
    
    private func refreshAppearanceData() {
        for item in mutableData.items {
            switch item.appearance {
            case .all:
                if !mutableData.items.contains(where: { $0.appearance == .light }) {
                    item.appearance = .light
                } else if !mutableData.items.contains(where: { $0.appearance == .dark }) {
                    item.appearance = .dark
                }
                
            default:
                break
            }
        }
    }
    
    private func refreshInfo(totalSize: UInt64) {
        let formattedTotalSize = getFormattedFilesize(filesize: totalSize)
        let images = Localization.Shared.images(param1: mutableData.items.count)
        mutableData.info = "\(images) • \(formattedTotalSize)"
    }
    
    private func calculateImageData(_ url: URL) -> (azimuth: Double, altitude: Double)? {
        guard
            let metadata = imageProvider.getImageMetadata(for: url),
            let latitude = metadata.latitude,
            let longitude = metadata.longitude,
            let date = metadata.createDate
        else {
            return nil
        }
        let timezone = metadata.timezone ?? .current
        let endOfDate = endOfDay(date: date)
        let timezoneHours = timezone.secondsFromGMT(for: endOfDate) / 60 / 60
        guard
            let solarAzimuth = try? solarService.azimuth(
                latitude: latitude,
                longitude: longitude,
                date: date,
                timezone: timezoneHours,
                dlstime: 0
            ),
            let solarAltitude = try? solarService.altitude(
                latitude: latitude,
                longitude: longitude,
                date: date,
                timezone: timezoneHours,
                dlstime: 0
            )
        else {
            return nil
        }
        let azimuth = roundDouble(solarAzimuth, places: 3)
        let altitude = roundDouble(solarAltitude, places: 3)
        return (azimuth, altitude)
    }

    private func calculateFilesize(_ url: URL) -> UInt64? {
        do {
            let filesize = try fileService.getFilesize(url)
            return filesize
        } catch {
            return nil
        }
    }

    private func getFormattedFilesize(filesize: UInt64) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(filesize), countStyle: .file)
    }

    private func isPrimaryIndex(_ index: Int) -> Bool {
        return index == 0
    }

    private func roundDouble(_ value: Double, places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
    }
    
    private func endOfDay(date: Date) -> Date {
        let calendar = getCurrentCalendar
        let endOfDayTimeInterval = TimeInterval(Constants.oneDaySeconds - 1)
        let endOfDay = calendar.startOfDay(for: date).addingTimeInterval(endOfDayTimeInterval)
        return endOfDay
    }
}
