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

extension TipContentView {
    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor
            
            public init(backgroundColor: NSColor) {
                self.backgroundColor = backgroundColor
            }
        }
        
        let ownStyle: OwnStyle
        let titleStyle: StyledLabel.Style
        let descriptionStyle: StyledLabel.Style
        let statusStyle: StyledLabel.Style
        let lineStyle: LineView.Style
        let pushButtonStyle: PushButton.Style
        
        public init(
            ownStyle: OwnStyle,
            titleStyle: StyledLabel.Style,
            descriptionStyle: StyledLabel.Style,
            statusStyle: StyledLabel.Style,
            lineStyle: LineView.Style,
            pushButtonStyle: PushButton.Style
        ) {
            self.ownStyle = ownStyle
            self.titleStyle = titleStyle
            self.descriptionStyle = descriptionStyle
            self.statusStyle = statusStyle
            self.lineStyle = lineStyle
            self.pushButtonStyle = pushButtonStyle
        }
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 20
        static let viewWidth: CGFloat = 500
        static let imageAspect: CGFloat = 9 / 16
        static let statusViewLeadingOffset: CGFloat = 20
        static let statusViewTopOffset: CGFloat = 20
        static let statusLabelHorizontalOffset: CGFloat = 10
        static let statusLabelVerticalOffset: CGFloat = 6
        static let textHorizontalOffset: CGFloat = 32
        static let titleTopOffset: CGFloat = 32
        static let descriptionTopOffset: CGFloat = 10
        static let lineTopOffset: CGFloat = 32
        static let lineHeight: CGFloat = 1
        static let buttonTopOffset: CGFloat = 20
        static let buttonWidth: CGFloat = 105
        static let buttonHeight: CGFloat = 32
        static let buttonBottomOffset: CGFloat = 20
        static let lineSpacing: CGFloat = 2
    }
}

// MARK: - Class

public class TipContentView: View {
    private lazy var titleLabel = StyledLabel()
    private lazy var descriptionLabel = StyledLabel()
    private lazy var imageView = ImageView()
    private lazy var statusLabel = StyledLabel()
    private lazy var lineView = LineView()
    private lazy var button = PushButton()
    
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
    
    private lazy var statusVisualEffectView: VisualEffectView = {
        let view = VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
        view.wantsLayer = true
        return view
    }()
    
    // MARK: - Initializer
    
    public override init() {
        super.init()
        setup()
    }
    
    // MARK: - Life Cycle
    
    public override func layout() {
        super.layout()
        statusVisualEffectView.layer?.cornerRadius = statusVisualEffectView.frame.height / 2
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
        addSubview(overlayView)
        overlayView.addSubview(visualEffectView)
        
        visualEffectView.contentView.addSubview(titleLabel)
        visualEffectView.contentView.addSubview(descriptionLabel)
        visualEffectView.contentView.addSubview(imageView)
        visualEffectView.contentView.addSubview(statusVisualEffectView)
        visualEffectView.contentView.addSubview(statusLabel)
        visualEffectView.contentView.addSubview(lineView)
        visualEffectView.contentView.addSubview(button)
    }
    
    private func setupConstraints() {
        setupContainerConstraints()
        setupStatusConstraints()
        setupImageConstraints()
        setupTextConstraints()
        setupButtonConstraints()
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
    
    private func setupStatusConstraints() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statusVisualEffectView.leadingAnchor.constraint(
                equalTo: visualEffectView.contentView.leadingAnchor,
                constant: Constants.statusViewLeadingOffset
            ),
            statusVisualEffectView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor, constant: Constants.statusViewTopOffset),
            
            statusLabel.leadingAnchor.constraint(
                equalTo: statusVisualEffectView.contentView.leadingAnchor,
                constant: Constants.statusLabelHorizontalOffset
            ),
            statusLabel.trailingAnchor.constraint(
                equalTo: statusVisualEffectView.contentView.trailingAnchor,
                constant: -Constants.statusLabelHorizontalOffset
            ),
            statusLabel.topAnchor.constraint(
                equalTo: statusVisualEffectView.contentView.topAnchor,
                constant: Constants.statusLabelVerticalOffset
            ),
            statusLabel.bottomAnchor.constraint(
                equalTo: statusVisualEffectView.contentView.bottomAnchor,
                constant: -Constants.statusLabelVerticalOffset
            )
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
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.titleTopOffset),
            titleLabel.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: Constants.textHorizontalOffset),
            titleLabel.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor, constant: -Constants.textHorizontalOffset),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor, constant: Constants.textHorizontalOffset),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: visualEffectView.contentView.trailingAnchor,
                constant: -Constants.textHorizontalOffset
            ),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.descriptionTopOffset)
        ])
    }
    
    private func setupButtonConstraints() {
        lineView.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lineView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Constants.lineTopOffset),
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
            descriptionLabel.attributedStringValue = makeDescriptionAttributedString()
        }
    }
    
    public var status: String? {
        didSet {
            statusLabel.stringValue = status ?? String()
        }
    }
    
    public var buttonTitle: String? {
        didSet {
            button.title = buttonTitle ?? String()
        }
    }
    
    public var image: NSImage? {
        didSet {
            imageView.image = image
        }
    }
    
    public var action: Button.Action? {
        didSet {
            button.onAction = action
        }
    }
    
    // MARK: - Private
    
    private func stylize() {
        visualEffectView.layer?.borderWidth = 1
        visualEffectView.layer?.borderColor = style?.lineStyle.color.cgColor
        overlayView.layer?.backgroundColor = style?.ownStyle.backgroundColor.cgColor
        
        titleLabel.style = style?.titleStyle
        descriptionLabel.style = style?.descriptionStyle
        statusLabel.style = style?.statusStyle
        lineView.style = style?.lineStyle
        button.style = style?.pushButtonStyle
        
        descriptionLabel.attributedStringValue = makeDescriptionAttributedString()
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
}
