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

extension WelcomeContentView.Style {
    static var `default`: WelcomeContentView.Style {
        return .init(
            ownStyle: .init(
                icon: Image.icon
            ),
            typeStyle: .init(
                headerStyle: .init(
                    font: Font.title2(.bold),
                    color: Color.label
                ),
                descriptionStyle: .init(
                    font: Font.body(.regular),
                    color: Color.secondaryLabel
                ),
                lineStyle: .init(
                    color: Color.typeSeparator
                ),
                itemStyle: .init(
                    ownStyle: .init(
                        imageColor: Color.typeImageContent,
                        selectedTintColor: Color.typeSelectedTint,
                        selectedBackgroundColor: Color.controlAccent
                    ),
                    titleStyle: .init(
                        font: Font.title3(.bold),
                        color: Color.label
                    ),
                    descriptionStyle: .init(
                        font: Font.body(.regular),
                        color: Color.secondaryLabel
                    )
                )
            ),
            welcomeStyle: .init(
                font: Font.largeTitle(.bold),
                color: Color.label
            ),
            versionStyle: .init(
                font: Font.title3(.regular),
                color: Color.secondaryLabel
            ),
            githubStyle: .init(
                font: Font.title3(.semibold),
                color: Color.secondaryLabel
            )
        )
    }
}
