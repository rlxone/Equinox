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
import XCTest

// swiftlint:disable force_unwrapping

class SolarCoreTests: XCTestCase {
    private var solarCore: SolarCoreImpl!
    
    override func setUpWithError() throws {
        solarCore = SolarCoreImpl()
    }
    
    func testAzimuth() {
        // Given
        let longitude = -87.623_177
        let latitude = 41.881_832
        let date = getDate(day: 28, month: 9, year: 2_021, hour: 12, minute: 0, second: 0)
        let result = 94.810_576_292_661_34
        
        // When
        let azimuth = solarCore.azimuth(latitude: latitude, longitude: longitude, date: date, timezone: 0, dlstime: 0)
        
        // Then
        XCTAssertEqual(azimuth, result)
    }
    
    func testAltitude() {
        // Given
        let longitude = -87.623_177
        let latitude = 41.881_832
        let date = getDate(day: 28, month: 9, year: 2_021, hour: 12, minute: 0, second: 0)
        let result = 2.316_156_681_523_694
        
        // When
        let altitude = solarCore.altitude(latitude: latitude, longitude: longitude, date: date, timezone: 0, dlstime: 0)
        
        // Then
        XCTAssertEqual(altitude, result)
    }
    
    private func getDate(day: Int, month: Int, year: Int, hour: Int, minute: Int, second: Int) -> Date {
        let timeZone = TimeZone(abbreviation: "GMT") ?? .current
        
        var dateComponents = DateComponents()
        dateComponents.timeZone = timeZone
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        
        let date = calendar.date(from: dateComponents)!
        return date
    }
}
