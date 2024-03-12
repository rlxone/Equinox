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

extension NotificationView {
    public typealias Action = () -> Void
    
    public struct Style {
        public struct OwnStyle {
            let borderColor: NSColor

            public init(borderColor: NSColor) {
                self.borderColor = borderColor
            }
        }

        let ownStyle: OwnStyle
        let textStyle: StyledLabel.Style

        public init(ownStyle: OwnStyle, textStyle: StyledLabel.Style) {
            self.ownStyle = ownStyle
            self.textStyle = textStyle
        }
    }

    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let shadowOpacity: Float = 0.15
        static let shadowRadius: CGFloat = 8
        static let shadowOffset = CGSize(width: 0, height: -2)
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 8
    }
}

// MARK: - Class

public final class NotificationView: View {
    private lazy var notificationLabel = StyledLabel()

    private lazy var visualEffectView: VisualEffectView = {
        let view = VisualEffectView(material: .popover, blendingMode: .withinWindow)
        view.wantsLayer = true
        view.layer?.borderWidth = Constants.borderWidth
        return view
    }()
    
    private lazy var shadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.anchorPoint = .zero
        layer.shadowOffset = Constants.shadowOffset
        layer.shadowRadius = Constants.shadowRadius
        layer.shadowOpacity = Constants.shadowOpacity
        return layer
    }()

    private lazy var shadowMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = .zero
        layer.fillRule = .evenOdd
        return layer
    }()
    
    // MARK: - Initializer
    
    public override init() {
        super.init()
        setup()
    }
    
    // MARK: - Life Cycle
    
    public override func layout() {
        super.layout()

        let radius = bounds.height / 2
        let path = NSBezierPath(roundedRect: bounds, xRadius: radius, yRadius: radius)

        visualEffectView.layer?.cornerRadius = radius
        shadowLayer.bounds = bounds
        shadowLayer.shadowPath = path.path

        path.appendRoundedRect(
            bounds.insetBy(
                dx: -Constants.shadowRadius * 2,
                dy: -Constants.shadowRadius * 2 - abs(Constants.shadowOffset.height)),
            xRadius: 0,
            yRadius: 0
        )

        shadowMaskLayer.path = path.path
        shadowMaskLayer.bounds = bounds
        shadowLayer.mask = shadowMaskLayer
    }
    
    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        action?()
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
        wantsLayer = true
        layer?.masksToBounds = false

        addSubview(visualEffectView)
        visualEffectView.addSubview(notificationLabel)
        layer?.insertSublayer(shadowLayer, at: 0)
    }

    private func setupConstraints() {
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            notificationLabel.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: Constants.horizontalPadding),
            notificationLabel.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -Constants.horizontalPadding),
            notificationLabel.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: Constants.verticalPadding),
            notificationLabel.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: -Constants.verticalPadding)
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

    public var text: String {
        get {
            return notificationLabel.stringValue
        }
        set {
            notificationLabel.stringValue = newValue
        }
    }
    
    public var action: Action?
    
    // MARK: - Private

    private func stylize() {
        visualEffectView.layer?.borderColor = style?.ownStyle.borderColor.cgColor
        notificationLabel.style = style?.textStyle
    }
}
