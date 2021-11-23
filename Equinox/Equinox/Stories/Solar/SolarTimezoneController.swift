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

extension SolarTimezoneController {
    struct TimezoneContainer {
        let timezone: TimeZone
        let name: String
        let continent: String
    }
}

final class SolarTimezoneController {
    private lazy var cachedTimezones = [TimezoneContainer]()
    
    // MARK: - Initializer
    
    init() {
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        for knownTimezone in TimeZone.knownTimeZoneIdentifiers {
            guard let timezone = TimeZone(identifier: knownTimezone) else {
                continue
            }
            let container = makeContainer(from: timezone)
            cachedTimezones.append(container)
        }
    }
    
    // MARK: - Public
    
    var currentContainer: TimezoneContainer {
        return makeContainer(from: .current)
    }
    
    var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "GMT") ?? .current
        return calendar
    }
    
    var timezones: [String: [String]] {
        return convertTimezones(from: cachedTimezones)
    }
    
    func findContainer(name: String) -> TimezoneContainer {
        return cachedTimezones.first { $0.name == name } ?? currentContainer
    }
    
    func compactTime(from progress: Float) -> String {
        let seconds = progress * 24 * 60 * 60
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        let formattedString = formatter.string(from: TimeInterval(seconds))
        
        return formattedString ?? String()
    }
    
    func merge(date: Date, timeOffset: Float) -> Date? {
        guard let time = getTime(for: date, with: timeOffset) else {
            return nil
        }
        return merge(date: date, time: time)
    }
    
    // MARK: - Private
    
    private func makeContainer(from timezone: TimeZone) -> TimezoneContainer {
        let abbreviation = getGMTHours(from: timezone)
        var timezoneContinent = String()
        var timezoneCity = String()
        var name = String()
        
        let components = timezone.identifier.components(separatedBy: "/")
        if let continent = components.first, let city = components.last {
            timezoneContinent = continent
            timezoneCity = city
        }
        
        if abbreviation.isEmpty {
            name = timezoneCity
        } else if abbreviation == "GMT" {
            name = timezoneCity
        } else {
            name = "\(timezoneCity) (\(abbreviation))"
        }
        
        return TimezoneContainer(
            timezone: timezone,
            name: name,
            continent: timezoneContinent
        )
    }
    
    private func convertTimezones(from timezones: [TimezoneContainer]) -> [String: [String]] {
        var timezonesDictionary: [String: [String]] = [:]
        
        for timezone in timezones {
            if !timezonesDictionary.keys.contains(timezone.continent) {
                timezonesDictionary[timezone.continent] = [String]()
            }
            timezonesDictionary[timezone.continent]?.append(timezone.name)
        }
        
        return timezonesDictionary
    }
    
    private func merge(date: Date, time: Date) -> Date? {
        let calendar = self.calendar
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = timeComponents.second
        
        return calendar.date(from: mergedComponents)
    }
    
    private func getTime(for date: Date, with offset: Float) -> Date? {
        let calendar = self.calendar
        let startTime = calendar.startOfDay(for: date)
        let seconds = Int(24 * 60 * 60 * offset)
        let date = calendar.date(byAdding: .second, value: seconds, to: startTime)
        return date
    }
    
    private func getGMTHours(from timezone: TimeZone) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        
        let hours = Float(timezone.secondsFromGMT()) / 60 / 60
        let formattedHours = formatter.string(from: NSNumber(value: hours)) ?? "0"
        var string: String
        
        if hours >= 0 {
            string = "GMT+\(formattedHours)"
        } else {
            string = "GMT\(formattedHours)"
        }
        
        return string
    }
}
