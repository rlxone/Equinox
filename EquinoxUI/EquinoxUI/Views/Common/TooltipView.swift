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

extension TooltipView {
    public struct Style {
        public struct OwnStyle {
            let borderColor: NSColor

            public init(borderColor: NSColor) {
                self.borderColor = borderColor
            }
        }

        let ownStyle: OwnStyle
        let titleStyle: StyledLabel.Style
        let descriptionStyle: StyledLabel.Style

        public init(
            ownStyle: OwnStyle,
            titleStyle: StyledLabel.Style,
            descriptionStyle: StyledLabel.Style
        ) {
            self.ownStyle = ownStyle
            self.titleStyle = titleStyle
            self.descriptionStyle = descriptionStyle
        }
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
        static let stackViewSpacing: CGFloat = 6
        static let stackViewHorizontalPadding: CGFloat = 10
        static let stackViewWidth: CGFloat = 250
        static let stackViewVerticalPadding: CGFloat = 12
        static let footerWidth: CGFloat = 300
    }
}

// MARK: - TooltipView

public final class TooltipView: VisualEffectView {
    private lazy var titleLabel = StyledLabel()
    private lazy var descriptionLabel = StyledLabel()
    
    private lazy var stackView: StackView = {
        let stackView = StackView()
        stackView.orientation = .vertical
        stackView.alignment = .left
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()
    
    private var footerConstraints: [NSLayoutConstraint]?
    private var stackViewFooterConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Initializer
    
    public init() {
        super.init(material: .toolTip, blendingMode: .withinWindow)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = Constants.cornerRadius
        layer?.borderWidth = Constants.borderWidth

        stackView.addView(titleLabel, in: .leading)
        stackView.addView(descriptionLabel, in: .leading)

        contentView.addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.stackViewHorizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.stackViewHorizontalPadding),
            stackView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.stackViewWidth),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.stackViewVerticalPadding)
        ])

        stackViewFooterConstraints = [
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.stackViewVerticalPadding)
        ]
        NSLayoutConstraint.activate(stackViewFooterConstraints)
    }
    
    // MARK: Public
    
    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }
    
    public func setText(title: String, description: String) {
        titleText = title
        descriptionText = description
    }

    public var titleText: String {
        get {
            return titleLabel.stringValue
        }
        set {
            titleLabel.stringValue = newValue
            titleLabel.sizeToFit()
        }
    }
    
    public var descriptionText: String {
        get {
            return descriptionLabel.stringValue
        }
        set {
            descriptionLabel.stringValue = newValue
            descriptionLabel.sizeToFit()
        }
    }
    
    public var footerView: NSView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let footerView = footerView {
                NSLayoutConstraint.deactivate(stackViewFooterConstraints)
                addSubview(footerView)
                if let footerConstraints = footerConstraints {
                    NSLayoutConstraint.activate(footerConstraints)
                } else {
                    footerView.translatesAutoresizingMaskIntoConstraints = false
                    let constraints = [
                        footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                        footerView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
                        footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                        footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                        footerView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.footerWidth)
                    ]
                    footerConstraints = constraints
                    NSLayoutConstraint.activate(constraints)
                }
            } else {
                NSLayoutConstraint.activate(stackViewFooterConstraints)
                if let footerConstraints = footerConstraints {
                    NSLayoutConstraint.deactivate(footerConstraints)
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func stylize() {
        layer?.borderColor = style?.ownStyle.borderColor.cgColor
        titleLabel.style = style?.titleStyle
        descriptionLabel.style = style?.descriptionStyle
    }
}
