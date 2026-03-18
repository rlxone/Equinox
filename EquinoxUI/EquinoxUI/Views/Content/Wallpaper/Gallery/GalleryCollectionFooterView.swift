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

extension GalleryCollectionFooterView {
    public typealias Action = () -> Void
    
    public struct Style {
        let infoStyle: StyledLabel.Style

        public init(infoStyle: StyledLabel.Style) {
            self.infoStyle = infoStyle
        }
    }
    
    private enum Constants {
        static let infoHorizontalOffset: CGFloat = 12
        static let infoVerticalOffset: CGFloat = 8
        static let animationDuration: TimeInterval = 0.3
        static let shadowOpacity: Float = 0.07
        static let shadowRadius: CGFloat = 10
        static let shadowOffset = CGSize(width: 0, height: -10)
    }
}

// MARK: - Class

public final class GalleryCollectionFooterView: View {
    private lazy var infoLabel = StyledLabel()
    
    private lazy var glassView: GlassView = {
        let view = GlassView(style: .regular, fallbackVisualEffect: (material: .toolTip, blendingMode: .withinWindow))
        view.wantsLayer = true
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

        glassView.cornerRadius = radius
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
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if !isHidden {
            action?()
        }
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
        
        addSubview(glassView)
        glassView.addSubview(infoLabel)
        layer?.insertSublayer(shadowLayer, at: 0)
    }

    private func setupConstraints() {
        glassView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            infoLabel.leadingAnchor.constraint(
                equalTo: glassView.contentView.leadingAnchor,
                constant: Constants.infoHorizontalOffset
            ),
            infoLabel.trailingAnchor.constraint(
                equalTo: glassView.contentView.trailingAnchor,
                constant: -Constants.infoHorizontalOffset
            ),
            infoLabel.topAnchor.constraint(equalTo: glassView.contentView.topAnchor, constant: Constants.infoVerticalOffset),
            infoLabel.bottomAnchor.constraint(equalTo: glassView.contentView.bottomAnchor, constant: -Constants.infoVerticalOffset)
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

    public var info: String? {
        didSet {
            infoLabel.stringValue = info ?? String()
        }
    }
    
    public var action: Action?

    public func animate(isHidden: Bool) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = Constants.animationDuration
            
            self.animator().alphaValue = isHidden ? 0 : 1
        }, completionHandler: {
            self.isHidden = isHidden
        })
    }
    
    // MARK: - Private

    private func stylize() {
        infoLabel.style = style?.infoStyle
    }
}
