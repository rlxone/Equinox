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

extension GalleryCollectionImageView {
    public enum Appearance {
        case vibrant
        case `default`
    }

    public enum Position {
        case topLeft
        case bottomLeft
    }

    public enum Size {
        case normal
        case small
    }

    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor
            let dashColor: NSColor
            let highlightDashColor: NSColor

            public init(
                backgroundColor: NSColor,
                dashColor: NSColor,
                highlightDashColor: NSColor
            ) {
                self.backgroundColor = backgroundColor
                self.dashColor = dashColor
                self.highlightDashColor = highlightDashColor
            }
        }

        let ownStyle: OwnStyle
        let numberStyle: StyledLabel.Style
        let smallNumberStyle: StyledLabel.Style

        public init(
            ownStyle: OwnStyle,
            numberStyle: StyledLabel.Style,
            smallNumberStyle: StyledLabel.Style
        ) {
            self.ownStyle = ownStyle
            self.numberStyle = numberStyle
            self.smallNumberStyle = smallNumberStyle
        }
    }
    
    private enum Constants {
        static let lineWidth: CGFloat = 1
        static let highlightLineWidth: CGFloat = 4
        static let cornerRadius: CGFloat = 4
        static let numberCornerRadius: CGFloat = 4
        static let numberLabelHorizontalOffset: CGFloat = 8
        static let numberLabelVerticalOffset: CGFloat = 4
        static let numberViewNormalOffset: CGFloat = 12
        static let numberViewSmallOffset: CGFloat = 6
    }
}

// MARK: - Class

public final class GalleryCollectionImageView: DashedView {
    private lazy var imageView = ImageView()
    private lazy var numberBlurView = VisualEffectView(material: .contentBackground, blendingMode: .withinWindow)
    private lazy var numberLabel = StyledLabel()

    private var numberStickConstraint: NSLayoutConstraint?
    private var numberLeadingConstraint: NSLayoutConstraint?

    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }

    // MARK: - Life Cycle

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
        lineWidth = Constants.lineWidth
        cornerRadius = Constants.cornerRadius

        imageView.imageContentsGravity = .resizeAspectFill
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = Constants.cornerRadius
        numberBlurView.wantsLayer = true
        numberBlurView.layer?.cornerRadius = Constants.numberCornerRadius

        contentView.addSubview(imageView)
        contentView.addSubview(numberBlurView)
        numberBlurView.addSubview(numberLabel)
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        numberBlurView.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            numberLabel.leadingAnchor.constraint(equalTo: numberBlurView.leadingAnchor, constant: Constants.numberLabelHorizontalOffset),
            numberLabel.trailingAnchor.constraint(equalTo: numberBlurView.trailingAnchor, constant: -Constants.numberLabelHorizontalOffset),
            numberLabel.topAnchor.constraint(equalTo: numberBlurView.topAnchor, constant: Constants.numberLabelVerticalOffset),
            numberLabel.bottomAnchor.constraint(equalTo: numberBlurView.bottomAnchor, constant: -Constants.numberLabelVerticalOffset)
        ])

        changeNumberPosition()
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var viewAppearance: Appearance = .default {
        didSet {
            switch viewAppearance {
            case .vibrant:
                numberBlurView.material = .toolTip

            case .default:
                numberBlurView.material = .contentBackground
            }
        }
    }

    public var position: Position = .bottomLeft {
        didSet {
            changeNumberPosition()
        }
    }

    public var size: Size = .small {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var number: Int? {
        didSet {
            if let number = number {
                numberLabel.stringValue = String(number)
            } else {
                numberLabel.stringValue = String()
            }
        }
    }

    public var image: NSImage? {
        didSet {
            imageView.image = image
        }
    }

    public var isHiglighted = false {
        didSet {
            if isHiglighted {
                highlight()
            } else {
                unhighlight()
            }
        }
    }

    // MARK: - Private

    private func stylize() {
        switch size {
        case .normal:
            numberLabel.style = style?.numberStyle

        case .small:
            numberLabel.style = style?.smallNumberStyle
        }

        layer?.backgroundColor = style?.ownStyle.backgroundColor.cgColor
        dashColor = isHiglighted ? style?.ownStyle.highlightDashColor : style?.ownStyle.dashColor
    }

    private func changeNumberPosition() {
        let offset: CGFloat

        switch size {
        case .normal:
            offset = Constants.numberViewNormalOffset

        case .small:
            offset = Constants.numberViewSmallOffset
        }

        if let numberLeadingConstraint = numberLeadingConstraint {
            removeConstraint(numberLeadingConstraint)
        }

        if let numberStickConstraint = numberStickConstraint {
            removeConstraint(numberStickConstraint)
        }

        numberLeadingConstraint = numberBlurView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset)
        numberLeadingConstraint?.isActive = true

        switch position {
        case .topLeft:
            numberStickConstraint = numberBlurView.topAnchor.constraint(equalTo: topAnchor, constant: offset)
            numberStickConstraint?.isActive = true

        case .bottomLeft:
            numberStickConstraint = numberBlurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset)
            numberStickConstraint?.isActive = true
        }
    }

    private func highlight() {
        lineDashPattern = nil
        lineWidth = Constants.highlightLineWidth
        stylize()
    }

    private func unhighlight() {
        dashColor = style?.ownStyle.dashColor
        lineWidth = Constants.lineWidth
        stylize()
    }
}
