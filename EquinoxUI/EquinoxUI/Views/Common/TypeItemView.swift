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

extension TypeItemView {
    public typealias Action = (TypeItemView) -> Void

    public struct Item {
        let image: NSImage
        let title: String
        let description: String

        public init(image: NSImage, title: String, description: String) {
            self.image = image
            self.title = title
            self.description = description
        }
    }

    public struct Style {
        public struct OwnStyle {
            let imageColor: NSColor
            let selectedTintColor: NSColor
            let selectedBackgroundColor: NSColor

            public init(imageColor: NSColor, selectedTintColor: NSColor, selectedBackgroundColor: NSColor) {
                self.imageColor = imageColor
                self.selectedTintColor = selectedTintColor
                self.selectedBackgroundColor = selectedBackgroundColor
            }
        }

        let ownStyle: OwnStyle
        let titleStyle: StyledLabel.Style
        let descriptionStyle: StyledLabel.Style

        public init(ownStyle: TypeItemView.Style.OwnStyle, titleStyle: StyledLabel.Style, descriptionStyle: StyledLabel.Style) {
            self.ownStyle = ownStyle
            self.titleStyle = titleStyle
            self.descriptionStyle = descriptionStyle
        }
    }

    private enum Constants {
        static let descriptionLabelLayoutWidth: CGFloat = 300
        static let cornerRadius: CGFloat = 8
        static let imageViewLeadingOffset: CGFloat = 16
        static let imageViewTopOffset: CGFloat = 16
        static let imageViewWidth: CGFloat = 32
        static let imageViewHeight: CGFloat = 32
        static let titleLabelTopOffset: CGFloat = 10
        static let titleLabelLeadingOffset: CGFloat = 20
        static let titleLabelTrailingOffset: CGFloat = 16
        static let descriptionLabelTrailingOffset: CGFloat = 16
        static let descriptionLabelTopOffset: CGFloat = 2
        static let descriptionLabelLeadingOffset: CGFloat = 20
        static let descriptionLabelBottomOffset: CGFloat = 10
    }
}

// MARK: - Class

public final class TypeItemView: View {
    private lazy var imageView = ImageView()

    private lazy var titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.cell?.usesSingleLineMode = false
        label.cell?.wraps = true
        label.cell?.lineBreakMode = .byWordWrapping
        return label
    }()

    private lazy var descriptionLabel: StyledLabel = {
        let label = StyledLabel()
        label.preferredMaxLayoutWidth = Constants.descriptionLabelLayoutWidth
        label.cell?.usesSingleLineMode = false
        label.cell?.wraps = true
        label.cell?.lineBreakMode = .byWordWrapping
        return label
    }()

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

    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        selectionAction?(self)
        if event.clickCount == 2 {
            action?(self)
        }
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = Constants.cornerRadius

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.imageViewLeadingOffset),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.imageViewTopOffset),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageViewWidth),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageViewHeight),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.titleLabelTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.titleLabelLeadingOffset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.titleLabelTrailingOffset),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.descriptionLabelTopOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.descriptionLabelLeadingOffset),
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

    public var item: Item? {
        didSet {
            imageView.image = item?.image
            titleLabel.stringValue = item?.title ?? String()
            descriptionLabel.stringValue = item?.description ?? String()
        }
    }

    public var isSelected = false {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var index: Int?

    public var action: Action?

    public var selectionAction: Action?

    // MARK: - Private

    private func stylize() {
        guard let style = style else {
            return
        }

        titleLabel.style = style.titleStyle
        descriptionLabel.style = style.descriptionStyle

        if isSelected {
            imageView.contentTintColor = style.ownStyle.selectedTintColor
            titleLabel.textColor = style.ownStyle.selectedTintColor
            descriptionLabel.textColor = style.ownStyle.selectedTintColor
            layer?.backgroundColor = style.ownStyle.selectedBackgroundColor.cgColor
        } else {
            imageView.contentTintColor = style.ownStyle.imageColor
            layer?.backgroundColor = .clear
        }
    }
}
