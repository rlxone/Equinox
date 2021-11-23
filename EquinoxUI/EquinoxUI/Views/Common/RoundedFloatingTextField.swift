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

// MARK: - Protocols

public protocol RoundedFloatingTextFieldDelegate: AnyObject {
    func textDidChange(_ textField: RoundedFloatingTextField)
}

// MARK: - Enums, Structs

extension RoundedFloatingTextField {
    public typealias CopyAction = (String) -> Void

    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor
            let borderColor: NSColor
            let textFont: NSFont
            let textColor: NSColor
            let placeholderColor: NSColor
            let copyImage: NSImage

            public init(
                backgroundColor: NSColor,
                borderColor: NSColor,
                textFont: NSFont,
                textColor: NSColor,
                placeholderColor: NSColor,
                copyImage: NSImage
            ) {
                self.backgroundColor = backgroundColor
                self.borderColor = borderColor
                self.textFont = textFont
                self.textColor = textColor
                self.placeholderColor = placeholderColor
                self.copyImage = copyImage
            }
        }

        let ownStyle: OwnStyle
        let pushButtonStyle: PushButton.Style

        public init(ownStyle: RoundedFloatingTextField.Style.OwnStyle, pushButtonStyle: PushButton.Style) {
            self.ownStyle = ownStyle
            self.pushButtonStyle = pushButtonStyle
        }
    }
    
    private enum Constants {
        static let stackViewSpacing: CGFloat = 6
        static let copyButtonWidth: CGFloat = 23
        static let copyButtonHeight: CGFloat = 23
        static let borderWidth: CGFloat = 1
    }
}

// MARK: - Class

public final class RoundedFloatingTextField: View {
    private lazy var titleLabel = Label()
    private lazy var copyButton = PushButton()

    private lazy var textField: FloatingTextField = {
        let textField = FloatingTextField()
        textField.floatingDelegate = self
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.focusRingType = .none
        return textField
    }()

    private lazy var stackView: StackView = {
        let stackView = StackView()
        stackView.spacing = Constants.stackViewSpacing
        return stackView
    }()
    
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
        wantsLayer = true
        layer?.borderWidth = Constants.borderWidth

        addSubview(stackView)
        stackView.addView(titleLabel, in: .leading)
        stackView.addView(textField, in: .leading)
        stackView.addView(copyButton, in: .trailing)
    }

    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        copyButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            copyButton.widthAnchor.constraint(equalToConstant: Constants.copyButtonWidth),
            copyButton.heightAnchor.constraint(equalToConstant: Constants.copyButtonHeight)
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

    public weak var delegate: RoundedFloatingTextFieldDelegate?

    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer?.cornerRadius = cornerRadius
        }
    }

    public var edgeInsets: NSEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            stackView.edgeInsets = edgeInsets
        }
    }

    public var isEditable: Bool {
        get {
            return textField.isEditable
        }
        set {
            textField.isEditable = newValue
        }
    }

    public var isSelectable: Bool {
        get {
            return textField.isSelectable
        }
        set {
            textField.isSelectable = newValue
        }
    }

    public var isCopyButtonHidden: Bool {
        get {
            return copyButton.isHidden
        }
        set {
            copyButton.isHidden = newValue
        }
    }

    public var title: String? {
        didSet {
            titleLabel.stringValue = title ?? String()
        }
    }

    public var text: String {
        get {
            return textField.stringValue
        }
        set {
            textField.stringValue = newValue
        }
    }

    public var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    public var copyAction: CopyAction? {
        didSet {
            copyButton.onAction = { [weak self] _ in
                let text = self?.textField.stringValue ?? String()
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([.string], owner: nil)
                pasteboard.setString(text, forType: .string)
                self?.copyAction?(text)
            }
        }
    }
    
    // MARK: - Private

    private func stylize() {
        layer?.backgroundColor = style?.ownStyle.backgroundColor.cgColor
        layer?.borderColor = style?.ownStyle.borderColor.cgColor
        titleLabel.font = style?.ownStyle.textFont
        titleLabel.textColor = style?.ownStyle.textColor
        textField.font = style?.ownStyle.textFont
        textField.textColor = style?.ownStyle.textColor
        copyButton.style = style?.pushButtonStyle
        copyButton.image = style?.ownStyle.copyImage

        updatePlaceholder()
    }

    private func updatePlaceholder() {
        guard let font = style?.ownStyle.textFont, let color = style?.ownStyle.placeholderColor else {
            return
        }
        let string = placeholder ?? String()
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: font
        ]
        let placeholderString = NSAttributedString(string: string, attributes: attributes)
        textField.placeholderAttributedString = placeholderString
    }
}

// MARK: - FloatingTextFieldDelegate

extension RoundedFloatingTextField: FloatingTextFieldDelegate {
    public func textDidChange(_ textField: FloatingTextField) {
        delegate?.textDidChange(self)
    }
    
    public func textDidTab(for view: NSView) {
    }
    
    public func textDidBackTab(for view: NSView) {
    }
}
