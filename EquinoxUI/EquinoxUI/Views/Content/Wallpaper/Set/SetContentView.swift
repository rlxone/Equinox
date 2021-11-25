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

extension SetContentView {
    public typealias Action = (Bool) -> Void
    
    public struct Link {
        let text: String
        let tag: String
        
        public init(text: String, tag: String) {
            self.text = text
            self.tag = tag
        }
    }
    
    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor
            let skipFont: NSFont
            let skipColor: NSColor
            let todoFont: NSFont
            let todoColor: NSColor
            let todoLinkFont: NSFont
            let todoLinkColor: NSColor
            
            public init(
                backgroundColor: NSColor,
                skipFont: NSFont,
                skipColor: NSColor,
                todoFont: NSFont,
                todoColor: NSColor,
                todoLinkFont: NSFont,
                todoLinkColor: NSColor
            ) {
                self.backgroundColor = backgroundColor
                self.skipFont = skipFont
                self.skipColor = skipColor
                self.todoFont = todoFont
                self.todoColor = todoColor
                self.todoLinkFont = todoLinkFont
                self.todoLinkColor = todoLinkColor
            }
        }
        
        let ownStyle: OwnStyle
        let titleStyle: StyledLabel.Style
        let descriptionStyle: StyledLabel.Style
        let lineStyle: LineView.Style
        let pushButtonStyle: PushButton.Style
        
        public init(
            ownStyle: OwnStyle,
            titleStyle: StyledLabel.Style,
            descriptionStyle: StyledLabel.Style,
            lineStyle: LineView.Style,
            pushButtonStyle: PushButton.Style
        ) {
            self.ownStyle = ownStyle
            self.titleStyle = titleStyle
            self.descriptionStyle = descriptionStyle
            self.lineStyle = lineStyle
            self.pushButtonStyle = pushButtonStyle
        }
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 20
        static let viewWidth: CGFloat = 500
        static let imageAspect: CGFloat = 9 / 16
        static let textHorizontalOffset: CGFloat = 32
        static let titleTopOffset: CGFloat = 32
        static let descriptionTopOffset: CGFloat = 10
        static let todoTopOffset: CGFloat = 10
        static let lineTopOffset: CGFloat = 32
        static let skipButtonTopOffset: CGFloat = 20
        static let skipButtonLeadingOffset: CGFloat = 32
        static let lineHeight: CGFloat = 1
        static let buttonTopOffset: CGFloat = 20
        static let buttonWidth: CGFloat = 105
        static let buttonHeight: CGFloat = 32
        static let buttonBottomOffset: CGFloat = 20
        static let lineSpacing: CGFloat = 2
    }
}

// MARK: - Class

public final class SetContentView: View {
    private lazy var titleLabel = StyledLabel()
    private lazy var descriptionLabel = StyledLabel()
    private lazy var imageView = ImageView()
    private lazy var lineView = LineView()
    private lazy var button = PushButton()
    
    private lazy var skipButton: NSButton = {
        let button = NSButton()
        button.setButtonType(.switch)
        return button
    }()
    
    private lazy var todoTextView: TextView = {
        let textView = TextView()
        textView.isEditable = false
        textView.drawsBackground = false
        return textView
    }()
    
    private lazy var overlayView: OverlayView = {
        let view = OverlayView()
        view.wantsLayer = true
        return view
    }()
    
    private lazy var visualEffectView: VisualEffectView = {
        let view = VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
        view.wantsLayer = true
        view.layer?.cornerRadius = Constants.cornerRadius
        return view
    }()
    
    private var internalLinks: [Link] = []
    
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
        addSubview(overlayView)
        overlayView.addSubview(visualEffectView)
        
        visualEffectView.contentView.addSubview(titleLabel)
        visualEffectView.contentView.addSubview(descriptionLabel)
        visualEffectView.contentView.addSubview(imageView)
        visualEffectView.contentView.addSubview(todoTextView)
        visualEffectView.contentView.addSubview(skipButton)
        visualEffectView.contentView.addSubview(lineView)
        visualEffectView.contentView.addSubview(button)
    }
    
    private func setupConstraints() {
        setupContainerConstraints()
        setupImageConstraints()
        setupTextConstraints()
        setupButtonsConstraints()
    }
    
    private func setupContainerConstraints() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            visualEffectView.widthAnchor.constraint(equalToConstant: Constants.viewWidth),
            visualEffectView.centerXAnchor.constraint(equalTo: centerXAnchor),
            visualEffectView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupImageConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: visualEffectView.widthAnchor, multiplier: Constants.imageAspect)
        ])
    }
    
    private func setupTextConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        todoTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.titleTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: Constants.textHorizontalOffset),
            titleLabel.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor, constant: -Constants.textHorizontalOffset),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: Constants.textHorizontalOffset),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: visualEffectView.contentView.trailingAnchor,
                constant: -Constants.textHorizontalOffset
            ),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.descriptionTopOffset),
            
            todoTextView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: Constants.textHorizontalOffset),
            todoTextView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor, constant: -Constants.textHorizontalOffset),
            todoTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.todoTopOffset)
        ])
    }
    
    private func setupButtonsConstraints() {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            skipButton.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: Constants.skipButtonLeadingOffset),
            skipButton.topAnchor.constraint(equalTo: todoTextView.bottomAnchor, constant: Constants.skipButtonTopOffset),
            
            lineView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: Constants.lineTopOffset),
            lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),
            
            button.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: Constants.buttonTopOffset),
            button.centerXAnchor.constraint(equalTo: visualEffectView.contentView.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            button.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor, constant: -Constants.buttonBottomOffset)
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
    
    public var title: String? {
        didSet {
            titleLabel.stringValue = title ?? String()
        }
    }
    
    public var descriptionTitle: String? {
        didSet {
            updateDescriptionText()
        }
    }
    
    public var buttonTitle: String? {
        didSet {
            button.title = buttonTitle ?? String()
        }
    }
    
    public var todoText: String? {
        didSet {
            updateTodoText()
        }
    }
    
    public var skipText: String? {
        didSet {
            skipButton.title = skipText ?? String()
        }
    }
    
    public var image: NSImage? {
        didSet {
            imageView.image = image
        }
    }
    
    public var links: [Link]? {
        didSet {
            internalLinks = links ?? []
            updateTodoText()
        }
    }
    
    public var action: Action? {
        didSet {
            button.onAction = { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.action?(self.skipButton.state == .on)
            }
        }
    }
    
    public var todoClickAction: TextView.ClickAction? {
        didSet {
            todoTextView.clickAction = todoClickAction
        }
    }
    
    // MARK: - Private
    
    private func stylize() {
        visualEffectView.layer?.borderWidth = 1
        visualEffectView.layer?.borderColor = style?.lineStyle.color.cgColor
        overlayView.layer?.backgroundColor = style?.ownStyle.backgroundColor.cgColor
        
        titleLabel.style = style?.titleStyle
        descriptionLabel.style = style?.descriptionStyle
        lineView.style = style?.lineStyle
        button.style = style?.pushButtonStyle
        
        updateSkipButtonStyle()
        updateDescriptionText()
        updateTodoText()
    }
    
    private func updateSkipButtonStyle() {
        guard let style = style else {
            return
        }
        
        if let mutableAttributedTitle = skipButton.attributedTitle.mutableCopy() as? NSMutableAttributedString {
            mutableAttributedTitle.addAttributes([
                .foregroundColor: style.ownStyle.skipColor,
                .font: style.ownStyle.skipFont
            ], range: NSRange(location: 0, length: mutableAttributedTitle.length))
            skipButton.attributedTitle = mutableAttributedTitle
        }
    }
    
    private func updateTodoText() {
        guard let style = style else {
            return
        }
        todoTextView.linkTextAttributes = [
            .underlineStyle: 0,
            .font: style.ownStyle.todoLinkFont,
            .foregroundColor: style.ownStyle.todoLinkColor,
            .cursor: NSCursor.pointingHand
        ]
        let string = makeTodoAttributedString()
        todoTextView.setAttributedString(string)
    }
    
    private func updateDescriptionText() {
        let string = makeDescriptionAttributedString()
        descriptionLabel.attributedStringValue = string
    }
    
    private func makeDescriptionAttributedString() -> NSAttributedString {
        let description = descriptionTitle ?? String()
        
        guard let style = style else {
            return NSAttributedString(string: description)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Constants.lineSpacing
        
        let string = NSAttributedString(
            string: description,
            attributes: [
                .font: style.descriptionStyle.font,
                .foregroundColor: style.descriptionStyle.color,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        return string
    }
    
    private func makeTodoAttributedString() -> NSAttributedString {
        let todoText = self.todoText ?? String()
        
        guard let style = style else {
            return NSAttributedString(string: todoText)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = Constants.lineSpacing
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: style.ownStyle.todoFont,
            .foregroundColor: style.ownStyle.todoColor,
            .cursor: NSCursor.arrow,
            .paragraphStyle: paragraphStyle
        ]
        
        let mutableString = NSMutableAttributedString(
            string: todoText,
            attributes: attributes
        )
        
        for link in internalLinks {
            guard
                let substringRange = todoText.range(of: link.text),
                let url = URL(string: link.tag)
            else {
                continue
            }
            mutableString.addAttribute(
                .link,
                value: url,
                range: NSRange(substringRange, in: todoText)
            )
        }
        
        return mutableString
    }
}
