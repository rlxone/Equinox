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

import EquinoxAssets
import EquinoxUI

extension SolarMainContentView.Style {
    static var `default`: SolarMainContentView.Style {
        return .init(
            ownStyle: .init(
                pinImage: Image.pin
            ),
            locationStyle: .init(
                ownStyle: .init(
                    contentBackgroundColor: Color.solarContent,
                    contentBackgroundBorderColor: Color.solarContentBorder,
                    locationImage: Image.location
                ),
                locationHeaderStyle: .init(
                    font: Font.title2(.bold),
                    color: Color.label
                ),
                dateHeaderStyle: .init(
                    font: Font.title2(.bold),
                    color: Color.label
                ),
                textFieldStyle: .init(
                    ownStyle: .init(
                        backgroundColor: Color.solarControlContent,
                        borderColor: Color.solarControlContentBorder,
                        textFont: Font.callout(.regular),
                        textColor: Color.label,
                        placeholderColor: Color.secondaryLabel,
                        copyImage: Image.copy
                    ),
                    pushButtonStyle: .default
                ),
                datePickerStyle: .init(
                    backgroundColor: Color.solarControlContent,
                    borderColor: Color.solarControlContentBorder,
                    textFont: Font.callout(.regular),
                    textColor: Color.label
                ),
                pushButtonStyle: .default
            ),
            timelineStyle: .init(
                ownStyle: .init(
                    contentBackgroundColor: Color.solarContent,
                    contentBackgroundBorderColor: Color.solarContentBorder
                ),
                interactiveLineChartStyle: .init(
                    lineColor: Color.solarLine,
                    chartColor: Color.solarChart,
                    bottomFont: Font.small(.regular),
                    bottomColor: Color.secondaryLabel,
                    progressFont: Font.small(.regular),
                    progressColor: Color.label,
                    progressLineColor: Color.controlAccent
                ),
                titleStyle: .init(
                    font: Font.title2(.bold),
                    color: Color.label
                ),
                timezoneAbbreviationStyle: .init(
                    ownStyle: .init(
                        backgroundColor: Color.solarContent,
                        borderColor: Color.solarContentBorder
                    ),
                    titleStyle: .init(
                        font: Font.callout(.regular),
                        color: Color.label
                    )
                ),
                timezoneDaylightSavingTimeStyle: .init(
                    ownStyle: .init(
                        backgroundColor: Color.solarContent,
                        borderColor: Color.solarContentBorder
                    ),
                    titleStyle: .init(
                        font: Font.callout(.regular),
                        color: Color.label
                    )
                ),
                timezoneMenuStyle: .init(
                    titleFont: Font.body(.regular),
                    titleColor: Color.label,
                    supplementaryTitleFont: Font.caption2(.regular),
                    supplementaryTitleColor: Color.secondaryLabel
                )
            ),
            resultStyle: .init(
                ownStyle: .init(
                    contentBackgroundColor: Color.solarContent,
                    contentBackgroundBorderColor: Color.solarContentBorder,
                    dragImage: Image.drag
                ),
                resultHeaderStyle: .init(
                    font: Font.title2(.bold),
                    color: Color.label
                ),
                textFieldStyle: .init(
                    ownStyle: .init(
                        backgroundColor: Color.solarControlContent,
                        borderColor: Color.solarControlContentBorder,
                        textFont: Font.callout(.regular),
                        textColor: Color.label,
                        placeholderColor: Color.secondaryLabel,
                        copyImage: Image.copy
                    ),
                    pushButtonStyle: .default
                )
            ),
            lineStyle: .init(
                color: Color.separator
            ),
            tooltipStyle: .default
        )
    }
}
