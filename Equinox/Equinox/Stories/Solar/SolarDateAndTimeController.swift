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

import EquinoxCore
import Foundation

extension SolarDateAndTimeController {
    struct ExtendedTimezone {
        let underlyingTimezone: TimeZone
        let city: String
        let continent: String
    }
    
    enum Constants {
        static let defaultTimeInSeconds = oneDaySeconds / 4 // 6:00 AM
        static let oneDaySeconds = 24 * 60 * 60
    }
}

final class SolarDateAndTimeController {
    private lazy var cachedTimezones = [String: ExtendedTimezone]()
    private lazy var currentDate = merge(date: Date(), seconds: currentTime) ?? Date()
    private lazy var currentTime = Constants.defaultTimeInSeconds
    private lazy var currentTimezone = makeTimezone(from: .current)
    
    // MARK: - Initializer
    
    init() {
        initialize()
    }
    
    private func initialize() {
        cachedTimezones = [:]
        for knownTimezone in TimeZone.knownTimeZoneIdentifiers {
            guard let timezone = TimeZone(identifier: knownTimezone) else {
                continue
            }
            let container = makeTimezone(from: timezone)
            cachedTimezones[timezone.identifier] = container
        }
    }
    
    // MARK: - Public
    
    func setDate(date: Date) {
        currentDate = merge(date: date, seconds: currentTime) ?? Date()
    }
    
    func setTime(timeOffset: Float) {
        currentTime = Int(Float(Constants.oneDaySeconds) * timeOffset)
        currentDate = merge(date: currentDate, seconds: currentTime) ?? Date()
    }
    
    func setTimezone(identifier: String) {
        currentTimezone = cachedTimezones[identifier] ?? currentTimezone
    }
    
    var selectedTimezone: ExtendedTimezone {
        return currentTimezone
    }
    
    var selectedDate: Date {
        return currentDate
    }
    
    var continentTimezones: [String: [ExtendedTimezone]] {
        return convertToContinentTimezones(timezones: cachedTimezones)
    }
    
    var abbreviation: String {
        return getGMTHours(
            from: currentTimezone.underlyingTimezone,
            date: endOfDay
        )
    }
    
    var timeOffset: Float {
        Float(currentTime) / Float(24 * 60 * 60)
    }
    
    func timezone(identifier: String) -> ExtendedTimezone {
        return cachedTimezones[identifier] ?? currentTimezone
    }
    
    func abbreviation(identifier: String) -> String {
        return getGMTHours(
            from: timezone(identifier: identifier).underlyingTimezone,
            date: endOfDay
        )
    }
    
    var isDaylightSavingTime: Bool {
        return currentTimezone.underlyingTimezone.isDaylightSavingTime(for: endOfDay)
    }
    
    var secondsFromGMT: Int {
        currentTimezone.underlyingTimezone.secondsFromGMT(for: endOfDay)
    }
    
    func convertToHours(seconds: Int) -> Int {
        return seconds / 60 / 60
    }
    
    func compactTime(timeOffset: Float) -> String {
        let seconds = timeOffset * Float(Constants.oneDaySeconds)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        let formattedString = formatter.string(from: TimeInterval(seconds))
        
        return formattedString ?? String()
    }
    
    // MARK: - Private
    
    private var endOfDay: Date {
        let calendar = getCurrentCalendar
        let endOfDayTimeInterval = TimeInterval(Constants.oneDaySeconds - 1)
        let endOfDay = calendar.startOfDay(for: currentDate).addingTimeInterval(endOfDayTimeInterval)
        return endOfDay
    }
    
    private func makeTimezone(from timezone: TimeZone) -> ExtendedTimezone {
        var continent = String()
        var city = String()
        
        let components = timezone.identifier.components(separatedBy: "/")
        if let timezoneContinent = components.first, let timezoneCity = components.last {
            continent = timezoneContinent
            city = timezoneCity
        }
        
        return ExtendedTimezone(underlyingTimezone: timezone, city: city, continent: continent)
    }
    
    private func convertToContinentTimezones(timezones: [String: ExtendedTimezone]) -> [String: [ExtendedTimezone]] {
        var timezonesDictionary: [String: [ExtendedTimezone]] = [:]
        
        for timezone in timezones {
            if !timezonesDictionary.keys.contains(timezone.value.continent) {
                timezonesDictionary[timezone.value.continent] = [ExtendedTimezone]()
            }
            timezonesDictionary[timezone.value.continent]?.append(timezone.value)
        }
        
        return timezonesDictionary
    }
    
    private func merge(date: Date, seconds: Int) -> Date? {
        let calendar = getCurrentCalendar
        
        let startTime = calendar.startOfDay(for: date)
        let timeDate = calendar.date(byAdding: .second, value: seconds, to: startTime) ?? date
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: timeDate)

        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = timeComponents.second
        
        return calendar.date(from: mergedComponents)
    }
    
    private func getGMTHours(from timezone: TimeZone, date: Date) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        
        let hours = Float(timezone.secondsFromGMT(for: date)) / 60 / 60
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
