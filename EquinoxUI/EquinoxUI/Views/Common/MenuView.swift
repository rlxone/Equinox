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

// MARK: - Enums, Structs

extension MenuView {
    public enum Item {
        case button(title: String, action: Button.Action)
        case separator
    }

    public struct Style {
        let buttonStyle: PushButton.Style
        let lineStyle: LineView.Style

        public init(
            buttonStyle: PushButton.Style,
            lineStyle: LineView.Style
        ) {
            self.buttonStyle = buttonStyle
            self.lineStyle = lineStyle
        }
    }

    private enum Constants {
        static let defaultSpacing: CGFloat = 11
        static let defaultButtonWidth: CGFloat = 100
        static let defaultButtonHeight: CGFloat = 32
        static let defaultLineWidth: CGFloat = 1
        static let defaultLineHeight: CGFloat = 23
    }
}

// MARK: - MenuView

public final class MenuView: StackView {
    public override init() {
        super.init()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        spacing = Constants.defaultSpacing
    }

    // MARK: - Public

    public var style: Style?

    public var items: [Item] = [] {
        didSet {
            arrangedSubviews.forEach {
                removeArrangedSubview($0)
            }
            for item in items {
                switch item {
                case .button(let title, let action):
                    addButton(title: title, action: action)

                case .separator:
                    addSeparator()
                }
            }
        }
    }

    // MARK: - Private

    private func addButton(title: String, action: @escaping Button.Action) {
        let button = PushButton()
        button.title = title
        button.onAction = action
        button.style = style?.buttonStyle
        button.translatesAutoresizingMaskIntoConstraints = false

        addArrangedSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Constants.defaultButtonWidth),
            button.heightAnchor.constraint(equalToConstant: Constants.defaultButtonHeight)
        ])
    }

    private func addSeparator() {
        let lineView = LineView()
        lineView.style = style?.lineStyle
        lineView.translatesAutoresizingMaskIntoConstraints = false

        addArrangedSubview(lineView)

        NSLayoutConstraint.activate([
            lineView.widthAnchor.constraint(equalToConstant: Constants.defaultLineWidth),
            lineView.heightAnchor.constraint(equalToConstant: Constants.defaultLineHeight)
        ])
    }
}
