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

extension TitleBarView {
    public struct Style {
        let titleStyle: TitleLabel.Style
        let titleLineStyle: TitleLineView.Style

        public init(
            titleStyle: TitleLabel.Style,
            titleLineStyle: TitleLineView.Style
        ) {
            self.titleStyle = titleStyle
            self.titleLineStyle = titleLineStyle
        }
    }

    private enum Constants {
        static let titleLineHeight: CGFloat = 1
    }
}

// MARK: - Class

public final class TitleBarView: View {
    private lazy var blurView = VisualEffectView(material: .titlebar, blendingMode: .withinWindow)
    private lazy var titleLabel = TitleLabel()
    private lazy var titleLineView = TitleLineView()

    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(blurView)
        blurView.contentView.addSubview(titleLabel)
        blurView.contentView.addSubview(titleLineView)
    }

    private func setupConstraints() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLineView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.titleLineHeight),

            titleLabel.centerXAnchor.constraint(equalTo: blurView.contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: blurView.contentView.centerYAnchor),

            titleLineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.titleLineHeight),
            titleLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLineView.heightAnchor.constraint(equalToConstant: Constants.titleLineHeight)
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            titleLabel.style = style?.titleStyle
            titleLineView.style = style?.titleLineStyle
        }
    }

    public var active: Bool {
        get {
            return blurView.active
        }
        set {
            blurView.active = newValue
            titleLabel.active = newValue
        }
    }

    public var title: String = String() {
        didSet {
            titleLabel.stringValue = title
        }
    }
}
