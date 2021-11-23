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

extension AppearanceItemView {
    public typealias Action = (Int?) -> Void

    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor
            let highlightColor: NSColor

            public init(backgroundColor: NSColor, highlightColor: NSColor) {
                self.backgroundColor = backgroundColor
                self.highlightColor = highlightColor
            }
        }

        let ownStyle: OwnStyle
        let titleStyle: StyledLabel.Style
        let descriptionStyle: StyledLabel.Style
        let appearanceStyle: AppearanceStyleView.Style

        public init(
            ownStyle: OwnStyle,
            titleStyle: StyledLabel.Style,
            descriptionStyle: StyledLabel.Style,
            appearanceStyle: AppearanceStyleView.Style
        ) {
            self.ownStyle = ownStyle
            self.titleStyle = titleStyle
            self.descriptionStyle = descriptionStyle
            self.appearanceStyle = appearanceStyle
        }
    }
    
    private enum Constants {
        static let appearanceLeadingOffset: CGFloat = 10
        static let appearanceWidth: CGFloat = 24
        static let appearanceHeight: CGFloat = 24
        static let titleLabelTopOffset: CGFloat = 10
        static let titleLabelLeadingOffset: CGFloat = 10
        static let titleLabelTrailingOffset: CGFloat = 10
        static let descriptionLabelTopOffset: CGFloat = 2
        static let descriptionLabelLeadingOffset: CGFloat = 10
        static let descriptionLabelTrailingOffset: CGFloat = 10
        static let descriptionLabelBottomOffset: CGFloat = 10
    }
}

// MARK: - Class

public final class AppearanceItemView: View {
    private lazy var titleLabel = StyledLabel()
    private lazy var descriptionLabel = StyledLabel()
    private lazy var appearanceStyleView = AppearanceStyleView()

    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }

    // MARK: - Life Cycle

    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        isSelected = true
    }

    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        didSelect?(index)
    }

    public override var wantsUpdateLayer: Bool {
        return true
    }

    public override func updateLayer() {
        super.updateLayer()
        stylize()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(appearanceStyleView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
    }

    private func setupConstraints() {
        appearanceStyleView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            appearanceStyleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.appearanceLeadingOffset),
            appearanceStyleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            appearanceStyleView.widthAnchor.constraint(equalToConstant: Constants.appearanceWidth),
            appearanceStyleView.heightAnchor.constraint(equalToConstant: Constants.appearanceHeight),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.titleLabelTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: appearanceStyleView.trailingAnchor, constant: Constants.titleLabelLeadingOffset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.titleLabelTrailingOffset),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.descriptionLabelTopOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: appearanceStyleView.trailingAnchor, constant: Constants.descriptionLabelLeadingOffset),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.descriptionLabelTrailingOffset),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.descriptionLabelBottomOffset)
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var index: Int?

    public var didSelect: Action?

    public var title: String = String() {
        didSet {
            titleLabel.stringValue = title
        }
    }

    public var titleDescription: String = String() {
        didSet {
            descriptionLabel.stringValue = titleDescription
        }
    }

    public var appearanceType: AppearanceType = .all {
        didSet {
            appearanceStyleView.type = appearanceType
        }
    }

    public var isSelected = false {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    // MARK: - Private

    private func stylize() {
        if isSelected {
            layer?.backgroundColor = style?.ownStyle.highlightColor.cgColor
        } else {
            layer?.backgroundColor = style?.ownStyle.backgroundColor.cgColor
        }
        titleLabel.style = style?.titleStyle
        descriptionLabel.style = style?.descriptionStyle
        appearanceStyleView.style = style?.appearanceStyle
    }
}
