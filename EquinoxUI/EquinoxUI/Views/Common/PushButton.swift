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

// swiftlint:disable file_length

import AppKit

// MARK: - Enums, Structs

extension PushButton {
    public struct Style {
        let font: NSFont
        let textColor: NSColor
        let disabledTextColor: NSColor
        let highlightTextColor: NSColor
        let graphiteHighlightTextColor: NSColor
        let accentColor: NSColor
        let backgroundColor: NSColor
        let borderColor: NSColor
        let innerShadowColor: NSColor

        public init(
            font: NSFont,
            textColor: NSColor,
            disabledTextColor: NSColor,
            highlightTextColor: NSColor,
            graphiteHighlightTextColor: NSColor,
            accentColor: NSColor,
            backgroundColor: NSColor,
            borderColor: NSColor,
            innerShadowColor: NSColor
        ) {
            self.font = font
            self.textColor = textColor
            self.disabledTextColor = disabledTextColor
            self.highlightTextColor = highlightTextColor
            self.graphiteHighlightTextColor = graphiteHighlightTextColor
            self.accentColor = accentColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.innerShadowColor = innerShadowColor
        }
    }
    
    public enum StyleOption {
        case automatic
    }
    
    public enum ContentSizeOption {
        case automatic
        case `default`
        case large
        case extraLarge
    }

    private enum Constants {
        static var cornerRadius: CGFloat {
            if #available(macOS 26, *) {
                return 7
            }
            return 5
        }
        static let borderWidth: CGFloat = 1
        static let innerShadowOffset: CGFloat = 0.5
        static let disabledAlphaValue: CGFloat = 0.5
        static let shadow1AnchorPoint: CGPoint = .zero
        static let shadow1Offset = CGSize(width: 0, height: 0.25)
        static let shadow1Opacity: Float = 0.3
        static let shadow1Radius: CGFloat = 0.5
        static let shadow1BackgroundColor = CGColor.clear
        static let shadow2AnchorPoint = CGPoint.zero
        static let shadow2Offset = CGSize(width: 0, height: 1)
        static let shadow2Opacity: Float = 0.1
        static let shadow2Radius: CGFloat = 1
        static let shadow2BackgroundColor = CGColor.clear
        static let borderAnchorPoint = CGPoint.zero
        static var borderCornerRadius: CGFloat {
            if #available(macOS 26, *) {
                return 8
            }
            return 6
        }
        static let borderBackgroundColor = CGColor.clear
        static let innerShadowOpacity: Float = 1
        static let innerShadowRadius: CGFloat = 0
    }
}

// MARK: - Class

// swiftlint:disable:next type_body_length
public final class PushButton: Button {
    private var isMouseDown = false
    private let styleOption: StyleOption
    private let contentSizeOption: ContentSizeOption
    private lazy var titleLabel = Label()
    private lazy var imageView = ImageView()

    private lazy var contentView: View = {
        let view = View()
        view.wantsLayer = true
        view.layer?.masksToBounds = false
        view.layer?.cornerRadius = Constants.cornerRadius
        return view
    }()

    private lazy var shadow1Layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = Constants.shadow1AnchorPoint
        layer.shadowOffset = Constants.shadow1Offset
        layer.shadowOpacity = Constants.shadow1Opacity
        layer.shadowRadius = Constants.shadow1Radius
        layer.cornerRadius = Constants.cornerRadius
        layer.backgroundColor = Constants.shadow1BackgroundColor
        return layer
    }()

    private lazy var shadow2Layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = Constants.shadow2AnchorPoint
        layer.shadowOffset = Constants.shadow2Offset
        layer.shadowOpacity = Constants.shadow2Opacity
        layer.shadowRadius = Constants.shadow2Radius
        layer.cornerRadius = Constants.cornerRadius
        layer.backgroundColor = Constants.shadow2BackgroundColor
        return layer
    }()

    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = Constants.borderAnchorPoint
        layer.cornerRadius = Constants.borderCornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.backgroundColor = Constants.borderBackgroundColor
        return layer
    }()
    
    private lazy var innerShadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = .zero
        layer.shadowOpacity = Constants.innerShadowOpacity
        layer.shadowRadius = Constants.innerShadowRadius
        return layer
    }()

    private lazy var shadowMask1Layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = .zero
        layer.fillRule = .evenOdd
        return layer
    }()

    private lazy var shadowMask2Layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = .zero
        layer.fillRule = .evenOdd
        return layer
    }()

    // MARK: - Initializer

    public init(style: StyleOption = .automatic, contentSize: ContentSizeOption = .automatic) {
        self.styleOption = style
        self.contentSizeOption = contentSize
        super.init()
        setup()
    }
    
    public override convenience init() {
        self.init(style: .automatic, contentSize: .automatic)
    }

    // MARK: - Life Cycle

    public override func layout() {
        super.layout()
        
        guard !usesNativeButton else {
            return
        }

        let path = NSBezierPath(
            roundedRect: contentView.bounds,
            xRadius: Constants.cornerRadius,
            yRadius: Constants.cornerRadius
        )
        let bounds = path.bounds

        shadow1Layer.bounds = bounds
        shadow1Layer.shadowPath = path.path

        shadow2Layer.bounds = bounds
        shadow2Layer.shadowPath = path.path

        borderLayer.frame = .init(
            x: -Constants.borderWidth,
            y: -Constants.borderWidth,
            width: bounds.width + Constants.borderWidth * 2,
            height: bounds.height + Constants.borderWidth * 2
        )

        path.appendRoundedRect(
            bounds.insetBy(dx: -Constants.borderWidth * 2, dy: -Constants.borderWidth * 2),
            xRadius: Constants.cornerRadius,
            yRadius: Constants.cornerRadius
        )

        shadowMask1Layer.bounds = bounds
        shadowMask1Layer.path = path.path

        shadowMask2Layer.bounds = bounds
        shadowMask2Layer.path = path.path

        shadow1Layer.mask = shadowMask1Layer
        shadow2Layer.mask = shadowMask2Layer

        let innerShadowPath = NSBezierPath(
            roundedRect: path.bounds.insetBy(dx: -Constants.innerShadowOffset, dy: -Constants.innerShadowOffset),
            xRadius: Constants.cornerRadius,
            yRadius: Constants.cornerRadius
        )

        let innerShadowReversedPath = NSBezierPath(
            roundedRect: path.bounds,
            xRadius: Constants.cornerRadius,
            yRadius: Constants.cornerRadius
        ).reversed

        innerShadowPath.append(innerShadowReversedPath)

        innerShadowLayer.bounds = bounds
        innerShadowLayer.shadowPath = innerShadowPath.path
    }

    public override var wantsUpdateLayer: Bool {
        return true
    }

    public override func updateLayer() {
        super.updateLayer()
        
        if usesNativeButton {
            stylizeNative()
        } else {
            stylize()
        }
    }

    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        guard isEnabled else {
            return
        }
        
        if usesNativeButton {
            trackNativeClick()
            return
        }

        isMouseDown = true
        runWithEffectiveAppearance {
            stylize()
        }

        while isMouseDown {
            guard let nextEvent = self.window?.nextEvent(matching: [.leftMouseUp]) else {
                continue
            }
            switch nextEvent.type {
            case .leftMouseUp:
                let mouseLocation = convert(nextEvent.locationInWindow, from: nil)
                let isInside = bounds.contains(mouseLocation)
                if isInside {
                    onAction?(self)
                }
                isMouseDown = false
                runWithEffectiveAppearance {
                    stylize()
                }
                return

            default:
                break
            }
        }
    }

    public override func mouseUp(with event: NSEvent) {
        guard !usesNativeButton else {
            isMouseDown = false
            highlight(false)
            return
        }
        
        super.mouseUp(with: event)

        isMouseDown = false
        runWithEffectiveAppearance {
            stylize()
        }
    }

    public override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            alphaValue = usesNativeButton ? 1 : (newValue ? 1 : Constants.disabledAlphaValue)
            runWithEffectiveAppearance {
                if self.usesNativeButton {
                    self.stylizeNative()
                } else {
                    self.stylize()
                }
            }
        }
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        if usesNativeButton {
            setupNativeView()
            return
        }
        
        wantsLayer = true
        layer?.masksToBounds = false
        contentView.layer?.masksToBounds = true

        layer?.insertSublayer(borderLayer, at: 0)
        layer?.insertSublayer(shadow2Layer, at: 0)
        layer?.insertSublayer(shadow1Layer, at: 0)
        contentView.layer?.addSublayer(innerShadowLayer)

        addSubview(contentView)
        contentView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        guard !usesNativeButton else {
            return
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                if self.usesNativeButton {
                    self.stylizeNative()
                } else {
                    self.stylize()
                }
            }
        }
    }

    public override var title: String {
        get {
            if usesNativeButton {
                return super.title
            }
            return titleLabel.stringValue
        }
        set {
            if usesNativeButton {
                super.title = newValue
                updateNativeImagePosition()
            } else {
                super.title = String()
                titleLabel.stringValue = newValue
            }
        }
    }

    public override var image: NSImage? {
        get {
            if usesNativeButton {
                return super.image
            }
            return imageView.image
        }
        set {
            if usesNativeButton {
                super.image = newValue
                updateNativeImagePosition()
            } else {
                imageView.image = newValue
                imageView.removeFromSuperview()
                if newValue != nil {
                    addImageView()
                }
            }
        }
    }

    // MARK: - Private

    private func stylize() {
        titleLabel.font = style?.font
        borderLayer.borderColor = style?.borderColor.cgColor
        innerShadowLayer.shadowColor = style?.innerShadowColor.cgColor
        if isMouseDown {
            contentView.layer?.backgroundColor = style?.accentColor.cgColor
            if NSColor.currentControlTint == .graphiteControlTint {
                titleLabel.textColor = style?.graphiteHighlightTextColor
                imageView.contentTintColor = style?.graphiteHighlightTextColor
            } else {
                titleLabel.textColor = style?.highlightTextColor
                imageView.contentTintColor = style?.highlightTextColor
            }
        } else {
            contentView.layer?.backgroundColor = style?.backgroundColor.cgColor
            if isEnabled {
                titleLabel.textColor = style?.textColor
                imageView.contentTintColor = style?.textColor
            } else {
                titleLabel.textColor = style?.disabledTextColor
                imageView.contentTintColor = style?.disabledTextColor
            }
        }
    }

    private func addImageView() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Native Look

extension PushButton {
    private func setupNativeView() {
        setButtonType(.momentaryPushIn)
        isBordered = true
        
        if #available(macOS 14.0, *) {
            bezelStyle = .push
        }
        
        applyNativeControlSize()
    }
    
    private var usesNativeButton: Bool {
        switch styleOption {
        case .automatic:
            if #available(macOS 26, *) {
                return true
            }
            return false
        }
    }
    
    private func stylizeNative() {
        updateNativeImagePosition()
    }
    
    private func updateNativeImagePosition() {
        let hasTitle = !super.title.isEmpty
        let hasImage = super.image != nil
        
        switch (hasTitle, hasImage) {
        case (true, true):
            imagePosition = .imageLeft
        case (true, false):
            imagePosition = .noImage
        case (false, true):
            imagePosition = .imageOnly
        case (false, false):
            imagePosition = .noImage
        }
    }
    
    private func trackNativeClick() {
        isMouseDown = true
        highlight(true)
        
        while isMouseDown {
            guard let nextEvent = window?.nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) else {
                continue
            }
            
            let mouseLocation = convert(nextEvent.locationInWindow, from: nil)
            let isInside = bounds.contains(mouseLocation)
            
            switch nextEvent.type {
            case .leftMouseDragged:
                highlight(isInside)
                
            case .leftMouseUp:
                highlight(false)
                if isInside {
                    onAction?(self)
                }
                isMouseDown = false
                return
                
            default:
                break
            }
        }
    }
    
    private func applyNativeControlSize() {
        switch contentSizeOption {
        case .automatic:
            if #available(macOS 26.0, *) {
                controlSize = .extraLarge
            } else if #available(macOS 11.0, *) {
                controlSize = .large
            } else {
                controlSize = .regular
            }
            
        case .default:
            controlSize = .regular
            
        case .large:
            if #available(macOS 11.0, *) {
                controlSize = .large
            } else {
                controlSize = .regular
            }
            
        case .extraLarge:
            if #available(macOS 26.0, *) {
                controlSize = .extraLarge
            } else if #available(macOS 11.0, *) {
                controlSize = .large
            } else {
                controlSize = .regular
            }
        }
    }
}
