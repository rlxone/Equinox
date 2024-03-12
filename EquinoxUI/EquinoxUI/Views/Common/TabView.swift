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

extension TabView {
    public typealias ChangeAction = (TabItemView) -> Void

    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor
            let borderColor: NSColor

            public init(backgroundColor: NSColor, borderColor: NSColor) {
                self.backgroundColor = backgroundColor
                self.borderColor = borderColor
            }
        }

        let ownStyle: OwnStyle
        let tabItemStyle: TabItemView.Style

        public init(
            ownStyle: OwnStyle,
            tabItemStyle: TabItemView.Style
        ) {
            self.ownStyle = ownStyle
            self.tabItemStyle = tabItemStyle
        }
    }

    public struct TabItem {
        let title: String

        public init(title: String) {
            self.title = title
        }
    }

    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let shadow1AnchorPoint: CGPoint = .zero
        static let shadow1Offset = CGSize(width: 0, height: -0.25)
        static let shadow1Opacity: Float = 0.3
        static let shadow1Radius: CGFloat = 0.5
        static let shadow1BackgroundColor = CGColor.clear
        static let shadow2AnchorPoint = CGPoint.zero
        static let shadow2Offset = CGSize(width: 0, height: -1)
        static let shadow2Opacity: Float = 0.1
        static let shadow2Radius: CGFloat = 1
        static let shadow2BackgroundColor = CGColor.clear
        static let borderAnchorPoint = CGPoint.zero
        static let borderBackgroundColor = CGColor.clear
    }
}

// MARK: - Class

public final class TabView: View {
    private lazy var visualEffectView = VisualEffectView(material: .windowBackground, blendingMode: .withinWindow)

    private lazy var stackView: StackView = {
        let view = StackView()
        view.orientation = .horizontal
        view.distribution = .fill
        view.spacing = 0
        view.wantsLayer = true
        return view
    }()

    private lazy var shadow1Layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = Constants.shadow1AnchorPoint
        layer.shadowOffset = Constants.shadow1Offset
        layer.shadowOpacity = Constants.shadow1Opacity
        layer.shadowRadius = Constants.shadow1Radius
        layer.backgroundColor = Constants.shadow1BackgroundColor
        return layer
    }()

    private lazy var shadow2Layer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = Constants.shadow2AnchorPoint
        layer.shadowOffset = Constants.shadow2Offset
        layer.shadowOpacity = Constants.shadow2Opacity
        layer.shadowRadius = Constants.shadow2Radius
        layer.backgroundColor = Constants.shadow2BackgroundColor
        return layer
    }()

    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = Constants.borderAnchorPoint
        layer.borderWidth = Constants.borderWidth
        layer.backgroundColor = Constants.borderBackgroundColor
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

    private weak var selectedTabItemView: TabItemView?

    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }

    // MARK: - Life Cycle

    public override func layout() {
        super.layout()

        let cornerRadius = frame.height / 2

        let path = NSBezierPath(
            roundedRect: bounds,
            xRadius: cornerRadius,
            yRadius: cornerRadius
        )

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
            xRadius: cornerRadius,
            yRadius: cornerRadius
        )

        shadowMask1Layer.bounds = bounds
        shadowMask1Layer.path = path.path

        shadowMask2Layer.bounds = bounds
        shadowMask2Layer.path = path.path

        shadow1Layer.mask = shadowMask1Layer
        shadow2Layer.mask = shadowMask2Layer

        stackView.layer?.cornerRadius = cornerRadius
        visualEffectView.layer?.cornerRadius = cornerRadius + Constants.borderWidth
        borderLayer.cornerRadius = cornerRadius + Constants.borderWidth
        shadow1Layer.cornerRadius = cornerRadius
        shadow2Layer.cornerRadius = cornerRadius
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
        stackView.layer?.masksToBounds = true
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.masksToBounds = true

        layer?.insertSublayer(borderLayer, at: 0)
        layer?.insertSublayer(shadow2Layer, at: 0)
        layer?.insertSublayer(shadow1Layer, at: 0)

        addSubview(visualEffectView)
        addSubview(stackView)
    }

    private func setupConstraints() {
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
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

    public var changeAction: ChangeAction?

    public var tabs: [TabItem] = [] {
        didSet {
            stackView.arrangedSubviews.forEach {
                stackView.removeArrangedSubview($0)
            }
            for (index, tab) in tabs.enumerated() {
                let tabItemView = TabItemView()
                tabItemView.title = tab.title
                tabItemView.index = index
                tabItemView.style = style?.tabItemStyle
                tabItemView.action = { [weak self] item in
                    self?.processAction(item)
                }
                stackView.addArrangedSubview(tabItemView)
                if index == 0 {
                    tabItemView.selected = true
                    selectedTabItemView = tabItemView
                }
            }
        }
    }
    
    // MARK: - Private
    
    private var tabViews: [TabItemView] {
        return stackView
            .arrangedSubviews
            .compactMap { $0 as? TabItemView }
    }

    private func stylize() {
        borderLayer.borderColor = style?.ownStyle.borderColor.cgColor
        stackView.backgroundColor = style?.ownStyle.backgroundColor
        for tabView in tabViews {
            tabView.style = style?.tabItemStyle
        }
    }

    private func processAction(_ item: TabItemView) {
        if selectedTabItemView != item {
            selectedTabItemView?.selected = false
            selectedTabItemView = item
            changeAction?(item)
        }
    }
}
