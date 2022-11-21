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

extension DragView {
    public struct Style {
        public struct OwnStyle {
            let image: NSImage
            let backgroundColor: NSColor
            let dashColor: NSColor
            let highlightDashColor: NSColor

            public init(
                image: NSImage,
                backgroundColor: NSColor,
                dashColor: NSColor,
                highlightDashColor: NSColor
            ) {
                self.image = image
                self.backgroundColor = backgroundColor
                self.dashColor = dashColor
                self.highlightDashColor = highlightDashColor
            }
        }

        let ownStyle: OwnStyle
        let titleStyle: StyledLabel.Style
        let supplementaryStyle: StyledLabel.Style
        let alternativeStyle: StyledLabel.Style
        let browseStyle: PushButton.Style

        public init(
            ownStyle: OwnStyle,
            titleStyle: StyledLabel.Style,
            supplementaryStyle: StyledLabel.Style,
            alternativeStyle: StyledLabel.Style,
            browseStyle: PushButton.Style
        ) {
            self.ownStyle = ownStyle
            self.titleStyle = titleStyle
            self.supplementaryStyle = supplementaryStyle
            self.alternativeStyle = alternativeStyle
            self.browseStyle = browseStyle
        }
    }

    private enum Constants {
        static let dashedLineWidth: CGFloat = 2
        static let highlightDashedLineWidth: CGFloat = 4
        static let dashedLineDashPattern: [NSNumber] = [8, 8]
        static let dashedLineCornerRadius: CGFloat = 20
        static let dashedViewWidth: CGFloat = 600
        static let imageViewTopOffset: CGFloat = 60
        static let titleLabelTopOffset: CGFloat = 40
        static let titleLabelLeadingOffset: CGFloat = 20
        static let titleLabelTrailingOffset: CGFloat = 20
        static let supplementaryLabelTopOffset: CGFloat = 8
        static let supplementaryLabelLeadingOffset: CGFloat = 20
        static let supplementaryLabelTrailingOffset: CGFloat = 20
        static let alternativeLabelTopOffset: CGFloat = 20
        static let alternativeLabelLeadingOffset: CGFloat = 20
        static let alternativeLabelTrailingOffset: CGFloat = 20
        static let browseButtonTopOffset: CGFloat = 20
        static let browseButtonWidth: CGFloat = 100
        static let browseButtonHeight: CGFloat = 32
        static let browseButtonBottomOffset: CGFloat = 40
    }
}

// MARK: - Class

public final class DragView: View {
    private lazy var dashedView: DashedView = {
        let view = DashedView()
        view.lineWidth = Constants.dashedLineWidth
        view.lineDashPattern = Constants.dashedLineDashPattern
        view.cornerRadius = Constants.dashedLineCornerRadius
        return view
    }()

    private lazy var imageView: ImageView = {
        let imageView = ImageView()
        imageView.unregisterDraggedTypes()
        return imageView
    }()

    private lazy var titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.alignment = .center
        return label
    }()

    private lazy var supplementaryLabel: StyledLabel = {
        let label = StyledLabel()
        label.alignment = .center
        return label
    }()

    private lazy var alternativeLabel: StyledLabel = {
        let label = StyledLabel()
        label.alignment = .center
        return label
    }()

    private lazy var browseButton = PushButton()

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
        addSubview(dashedView)
        dashedView.contentView.addSubview(imageView)
        dashedView.contentView.addSubview(titleLabel)
        dashedView.contentView.addSubview(supplementaryLabel)
        dashedView.contentView.addSubview(alternativeLabel)
        dashedView.contentView.addSubview(browseButton)
    }

    private func setupConstraints() {
        dashedView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        supplementaryLabel.translatesAutoresizingMaskIntoConstraints = false
        alternativeLabel.translatesAutoresizingMaskIntoConstraints = false
        browseButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dashedView.centerXAnchor.constraint(equalTo: centerXAnchor),
            dashedView.centerYAnchor.constraint(equalTo: centerYAnchor),
            dashedView.widthAnchor.constraint(equalToConstant: Constants.dashedViewWidth),

            imageView.topAnchor.constraint(equalTo: dashedView.contentView.topAnchor, constant: Constants.imageViewTopOffset),
            imageView.centerXAnchor.constraint(equalTo: dashedView.contentView.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.titleLabelTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: dashedView.contentView.leadingAnchor, constant: Constants.titleLabelLeadingOffset),
            titleLabel.trailingAnchor.constraint(equalTo: dashedView.contentView.trailingAnchor, constant: -Constants.titleLabelTrailingOffset),

            supplementaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.supplementaryLabelTopOffset),
            supplementaryLabel.leadingAnchor.constraint(
                equalTo: dashedView.contentView.leadingAnchor,
                constant: Constants.supplementaryLabelLeadingOffset
            ),
            supplementaryLabel.trailingAnchor.constraint(
                equalTo: dashedView.contentView.trailingAnchor,
                constant: -Constants.supplementaryLabelTrailingOffset
            ),

            alternativeLabel.topAnchor.constraint(equalTo: supplementaryLabel.bottomAnchor, constant: Constants.alternativeLabelTopOffset),
            alternativeLabel.leadingAnchor.constraint(
                equalTo: dashedView.contentView.leadingAnchor,
                constant: Constants.alternativeLabelLeadingOffset
            ),
            alternativeLabel.trailingAnchor.constraint(
                equalTo: dashedView.contentView.trailingAnchor,
                constant: -Constants.alternativeLabelTrailingOffset
            ),

            browseButton.topAnchor.constraint(equalTo: alternativeLabel.bottomAnchor, constant: Constants.browseButtonTopOffset),
            browseButton.centerXAnchor.constraint(equalTo: dashedView.contentView.centerXAnchor),
            browseButton.widthAnchor.constraint(equalToConstant: Constants.browseButtonWidth),
            browseButton.heightAnchor.constraint(equalToConstant: Constants.browseButtonHeight),
            browseButton.bottomAnchor.constraint(equalTo: dashedView.contentView.bottomAnchor, constant: -Constants.browseButtonBottomOffset)
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

    public var isHighlighed: Bool = false {
        didSet {
            if isHighlighed {
                highlight()
            } else {
                unhighlight()
            }
        }
    }

    public var title: String {
        get {
            return titleLabel.stringValue
        }
        set {
            titleLabel.stringValue = newValue
        }
    }

    public var supplementaryTitle: String {
        get {
            return supplementaryLabel.stringValue
        }
        set {
            supplementaryLabel.stringValue = newValue
        }
    }

    public var alternativeTitle: String {
        get {
            return alternativeLabel.stringValue
        }
        set {
            alternativeLabel.stringValue = newValue
        }
    }

    public var browseTitle: String {
        get {
            return browseButton.title
        }
        set {
            browseButton.title = newValue
        }
    }

    public var browseAction: Button.Action? {
        didSet {
            browseButton.onAction = browseAction
        }
    }

    // MARK: - Private

    private func stylize() {
        imageView.image = style?.ownStyle.image
        titleLabel.style = style?.titleStyle
        supplementaryLabel.style = style?.supplementaryStyle
        alternativeLabel.style = style?.alternativeStyle
        browseButton.style = style?.browseStyle

        dashedView.layer?.backgroundColor = style?.ownStyle.backgroundColor.cgColor

        if isHighlighed {
            dashedView.dashColor = style?.ownStyle.highlightDashColor
        } else {
            dashedView.dashColor = style?.ownStyle.dashColor
        }
    }

    private func highlight() {
        dashedView.lineDashPattern = nil
        dashedView.lineWidth = Constants.highlightDashedLineWidth
        runWithEffectiveAppearance {
            stylize()
        }
    }

    private func unhighlight() {
        dashedView.lineWidth = Constants.dashedLineWidth
        dashedView.lineDashPattern = Constants.dashedLineDashPattern
        runWithEffectiveAppearance {
            stylize()
        }
    }
}
