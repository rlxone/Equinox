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

extension ToolBarView {
    public struct Style {
        public struct OwnStyle {
            let backImage: NSImage
            let backImageColor: NSColor

            public init(backImage: NSImage, backImageColor: NSColor) {
                self.backImage = backImage
                self.backImageColor = backImageColor
            }
        }

        let ownStyle: OwnStyle
        let titleStyle: StyledLabel.Style
        let menuStyle: MenuView.Style
        let lineView: LineView.Style

        public init(
            ownStyle: OwnStyle,
            titleStyle: StyledLabel.Style,
            menuStyle: MenuView.Style,
            lineView: LineView.Style
        ) {
            self.ownStyle = ownStyle
            self.titleStyle = titleStyle
            self.menuStyle = menuStyle
            self.lineView = lineView
        }
    }
    
    private enum Constants {
        static let stackViewSpacing: CGFloat = 12
        static let backButtonLeadingOffset: CGFloat = 40
        static let backButtonTopOffset: CGFloat = 32
        static let menuTrailingOffset: CGFloat = 40
        static let menuBottomOffset: CGFloat = 14
        static let lineHeight: CGFloat = 1
    }
}

// MARK: - Class

public final class ToolBarView: VisualEffectView {
    private lazy var titleLabel = StyledLabel()
    private lazy var backImageView = ImageView()
    private lazy var menuView = MenuView()
    private lazy var lineView = LineView()
    private lazy var backButton = ContainerButton()

    private lazy var stackView: StackView = {
        let stackView = StackView()
        stackView.alignment = .centerY
        stackView.distribution = .fill
        stackView.orientation = .horizontal
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()

    // MARK: - Initializer

    public init() {
        super.init(material: .windowBackground, blendingMode: .withinWindow)
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
        wantsLayer = true
        layer?.masksToBounds = false
        contentView.wantsLayer = true
        contentView.layer?.masksToBounds = false

        backImageView.isHidden = true
        backButton.isInteractionsEnabled = false

        stackView.addArrangedSubview(backImageView)
        stackView.addArrangedSubview(titleLabel)

        backButton.addSubview(stackView)

        contentView.addSubview(menuView)
        contentView.addSubview(lineView)
        contentView.addSubview(backButton)
    }

    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        menuView.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.backButtonLeadingOffset),
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.backButtonTopOffset),

            stackView.leadingAnchor.constraint(equalTo: backButton.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: backButton.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: backButton.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: backButton.bottomAnchor),

            menuView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.menuTrailingOffset),
            menuView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.menuBottomOffset),

            lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight)
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

    public var largeTitleText: String {
        get {
            return titleLabel.stringValue
        }
        set {
            titleLabel.stringValue = newValue
        }
    }

    public var isBackButtonEnabled: Bool = false {
        didSet {
            backImageView.isHidden = !isBackButtonEnabled
            backButton.isInteractionsEnabled = isBackButtonEnabled
        }
    }

    public var backButtonAction: Button.Action? {
        didSet {
            backButton.onAction = backButtonAction
        }
    }

    public var menuItems: [MenuView.Item] {
        get {
            return menuView.items
        }
        set {
            menuView.items = newValue
        }
    }
    
    // MARK: - Private
    
    private func stylize() {
        titleLabel.style = style?.titleStyle
        menuView.style = style?.menuStyle
        lineView.style = style?.lineView

        backImageView.image = style?.ownStyle.backImage
        backImageView.contentTintColor = style?.ownStyle.backImageColor
    }
}
