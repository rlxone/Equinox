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

extension BottomBarView {
    public struct Style {
        let buttonStyle: PushButton.Style

        public init(buttonStyle: PushButton.Style) {
            self.buttonStyle = buttonStyle
        }
    }
    
    private enum Constants {
        static let controlAreaHeight: CGFloat = 112
        static let translucentEdgeHeight: CGFloat = 32
        static let buttonWidth: CGFloat = 100
        static let buttonHeight: CGFloat = 32
        static let horizontalSpacing: CGFloat = 24
        static let verticalSpacing: CGFloat = 16
        static let horizontalInset: CGFloat = 24
    }
}

// MARK: - Class

public final class BottomBarView: View {
    public static let preferredHeight = Constants.controlAreaHeight

    private lazy var backgroundView = VisualEffectView(
        material: .headerView,
        blendingMode: .withinWindow
    )
    private lazy var separatorView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.separatorColor.cgColor
        return view
    }()
    private lazy var button = PushButton()
    private lazy var infoLabel = NSTextField(labelWithString: "")
    private lazy var accessoryContainer = NSView()
    private lazy var flexibleSpace = NSView()
    private lazy var actionStack: NSStackView = {
        let stack = NSStackView(views: [infoLabel, button])
        stack.orientation = .vertical
        stack.alignment = .trailing
        stack.spacing = Constants.verticalSpacing
        return stack
    }()
    private lazy var footerStack: NSStackView = {
        let stack = NSStackView(
            views: [accessoryContainer, flexibleSpace, actionStack]
        )
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = Constants.horizontalSpacing
        return stack
    }()
    private var accessoryHeightConstraint: NSLayoutConstraint?

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
        accessoryContainer.isHidden = true
        backgroundView.maskImage = makeBackgroundMask()
        infoLabel.textColor = .labelColor
        infoLabel.font = .systemFont(ofSize: 13)
        flexibleSpace.setContentHuggingPriority(.defaultLow, for: .horizontal)
        flexibleSpace.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )
        addSubview(backgroundView)
        addSubview(separatorView)
        addSubview(footerStack)
    }

    private func makeBackgroundMask() -> NSImage {
        let height = Int(Self.preferredHeight)
        let image = NSImage(size: NSSize(width: 1, height: CGFloat(height)))
        image.lockFocus()

        for row in 0..<height {
            let distanceFromTop = CGFloat(height - row)
            let alpha = min(1, 0.8 + distanceFromTop
                / Constants.translucentEdgeHeight * 0.2)
            NSColor.white.withAlphaComponent(alpha).setFill()
            NSRect(x: 0, y: CGFloat(row), width: 1, height: 1).fill()
        }

        image.unlockFocus()
        return image
    }
    
    private func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        actionStack.translatesAutoresizingMaskIntoConstraints = false
        accessoryContainer.translatesAutoresizingMaskIntoConstraints = false
        footerStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            button.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            footerStack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Constants.horizontalInset
            ),
            footerStack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Constants.horizontalInset
            ),
            footerStack.centerYAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Constants.controlAreaHeight / 2
            )
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            button.style = style?.buttonStyle
        }
    }

    public var accessoryView: NSView? {
        didSet {
            accessoryContainer.subviews.forEach { $0.removeFromSuperview() }
            guard let accessoryView = accessoryView else {
                accessoryHeightConstraint?.isActive = false
                accessoryHeightConstraint = nil
                accessoryContainer.isHidden = true
                return
            }

            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            accessoryContainer.addSubview(accessoryView)
            NSLayoutConstraint.activate([
                accessoryView.leadingAnchor.constraint(
                    equalTo: accessoryContainer.leadingAnchor
                ),
                accessoryView.trailingAnchor.constraint(
                    equalTo: accessoryContainer.trailingAnchor
                ),
                accessoryView.topAnchor.constraint(
                    equalTo: accessoryContainer.topAnchor
                ),
                accessoryView.bottomAnchor.constraint(
                    equalTo: accessoryContainer.bottomAnchor
                )
            ])
            accessoryHeightConstraint?.isActive = false
            let heightConstraint = accessoryContainer.heightAnchor
                .constraint(equalTo: accessoryView.heightAnchor)
            accessoryHeightConstraint = heightConstraint
            NSLayoutConstraint.activate([
                heightConstraint,
                accessoryContainer.widthAnchor.constraint(
                    equalTo: accessoryView.widthAnchor
                )
            ])
            accessoryContainer.isHidden = false
        }
    }

    public var buttonAction: Button.Action? {
        didSet {
            button.onAction = buttonAction
        }
    }

    public var infoText: String {
        get { infoLabel.stringValue }
        set { infoLabel.stringValue = newValue }
    }

    public var buttonTitle: String {
        get {
            return button.title
        }
        set {
            button.title = newValue
        }
    }

    public var isButtonEnabled: Bool {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }
}
