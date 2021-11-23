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

public final class GalleryModel {
    public enum MutateField {
        case appearance(AppearanceType)
        case primary(Bool)
        case azimuth(Double?)
        case altitude(Double?)
        case time(Date?)
    }

    public var number: Int
    public let url: URL
    public var appearance: AppearanceType
    public var primary: Bool
    public var azimuth: Double?
    public var altitude: Double?
    public var time: Date?
    
    public init(
        number: Int,
        url: URL,
        appearance: AppearanceType,
        primary: Bool,
        azimuth: Double?,
        altitude: Double?,
        time: Date?
    ) {
        self.number = number
        self.url = url
        self.appearance = appearance
        self.primary = primary
        self.azimuth = azimuth
        self.altitude = altitude
        self.time = time
    }
}

// MARK: - Equatable

extension GalleryModel: Equatable {
    public static func == (lhs: GalleryModel, rhs: GalleryModel) -> Bool {
        return lhs.number == rhs.number
    }
}
