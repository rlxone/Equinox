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

extension GalleryCollectionButtonsView {
    public typealias PrimaryChangeAction = (PrimaryButton) -> Void
    public typealias AppearanceTypeChangeAction = (AppearanceType) -> Void

    public enum Orientation {
        case vertical
        case horizontal
    }

    public enum Appearance {
        case vibrant
        case `default`
    }

    public struct Style {
        public struct OwnStyle {
            let stackBackgroundColor: NSColor
            let stackVibrantBackgroundColor: NSColor
            let stackBorderColor: NSColor

            public init(
                stackBackgroundColor: NSColor,
                stackVibrantBackgroundColor: NSColor,
                stackBorderColor: NSColor
            ) {
                self.stackBackgroundColor = stackBackgroundColor
                self.stackVibrantBackgroundColor = stackVibrantBackgroundColor
                self.stackBorderColor = stackBorderColor
            }
        }

        let ownStyle: OwnStyle
        let dynamicStyle: DynamicButton.Style
        let primaryStyle: PrimaryButton.Style

        public init(
            ownStyle: OwnStyle,
            dynamicStyle: DynamicButton.Style,
            primaryStyle: PrimaryButton.Style
        ) {
            self.ownStyle = ownStyle
            self.dynamicStyle = dynamicStyle
            self.primaryStyle = primaryStyle
        }
    }

    private enum Constants {
        static var cornerRadius: CGFloat {
            if #available(macOS 26, *) {
                return 10
            }
            return 4
        }
        static let borderWidth: CGFloat = 1
        static let buttonSize: CGFloat = 24
        static let tooltipPresentDelayMilliseconds = 1_000
        static let shadowOffset: CGSize = CGSize(width: 0, height: -10)
        static let shadowRadius: CGFloat = 10
        static let shadowOpacity: Float = 0.06
    }
}

// MARK: - Class

public final class GalleryCollectionButtonsView: View {
    private lazy var lightButton = makeAppearanceButton(
        identifier:
            GalleryContentView.TooltipIdentifier.lightAppearance.rawValue
    )
    private lazy var darkButton = makeAppearanceButton(
        identifier:
            GalleryContentView.TooltipIdentifier.darkAppearance.rawValue
    )
    private lazy var primaryButton: PrimaryButton = {
        let button = PrimaryButton()
        button.showTooltip = true
        button.tooltipPresentDelayMilliseconds =
            Constants.tooltipPresentDelayMilliseconds
        button.tooltipIdentifier =
            GalleryContentView.TooltipIdentifier.preview.rawValue
        return button
    }()

    private lazy var lightIconView = makeSymbolView("sun.max.fill")
    private lazy var darkIconView = makeSymbolView("moon.fill")
    private lazy var previewIconView = makeSymbolView("magnifyingglass")

    private lazy var visualEffectView: VisualEffectView = {
        let visualEffectView = VisualEffectView(material: .toolTip, blendingMode: .withinWindow)
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = Constants.cornerRadius
        return visualEffectView
    }()

    private lazy var stackView: StackView = {
        let stackView = StackView()
        stackView.wantsLayer = true
        stackView.layer?.cornerRadius = Constants.cornerRadius
        stackView.layer?.borderWidth = Constants.borderWidth
        stackView.spacing = 0
        return stackView
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
    
    public override func layout() {
        super.layout()

        let path = NSBezierPath(roundedRect: bounds, xRadius: Constants.cornerRadius, yRadius: Constants.cornerRadius)
        shadowLayer.bounds = bounds
        shadowLayer.shadowPath = path.path
    }
    
    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
        setupActions()
    }

    private func setupView() {
        addSubview(visualEffectView)
        addSubview(stackView)

        wantsLayer = true
        layer?.masksToBounds = false
        layer?.insertSublayer(shadowLayer, at: 0)
        
        visualEffectView.isHidden = true

        stackView.addView(lightButton, in: .center)
        stackView.addView(darkButton, in: .center)
        stackView.addView(primaryButton, in: .center)

        lightButton.addSubview(lightIconView)
        darkButton.addSubview(darkIconView)
        primaryButton.addSubview(previewIconView)
    }

    private func setupConstraints() {
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        lightButton.translatesAutoresizingMaskIntoConstraints = false
        darkButton.translatesAutoresizingMaskIntoConstraints = false
        lightIconView.translatesAutoresizingMaskIntoConstraints = false
        darkIconView.translatesAutoresizingMaskIntoConstraints = false
        previewIconView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            primaryButton.widthAnchor.constraint(
                equalToConstant: Constants.buttonSize
            ),
            primaryButton.heightAnchor.constraint(
                equalToConstant: Constants.buttonSize
            ),

            lightButton.widthAnchor.constraint(
                equalToConstant: Constants.buttonSize
            ),
            lightButton.heightAnchor.constraint(
                equalToConstant: Constants.buttonSize
            ),

            darkButton.widthAnchor.constraint(
                equalToConstant: Constants.buttonSize
            ),
            darkButton.heightAnchor.constraint(
                equalToConstant: Constants.buttonSize
            ),

            lightIconView.centerXAnchor.constraint(
                equalTo: lightButton.centerXAnchor
            ),
            lightIconView.centerYAnchor.constraint(
                equalTo: lightButton.centerYAnchor
            ),
            lightIconView.widthAnchor.constraint(equalToConstant: 16),
            lightIconView.heightAnchor.constraint(equalToConstant: 16),

            darkIconView.centerXAnchor.constraint(
                equalTo: darkButton.centerXAnchor
            ),
            darkIconView.centerYAnchor.constraint(
                equalTo: darkButton.centerYAnchor
            ),
            darkIconView.widthAnchor.constraint(equalToConstant: 16),
            darkIconView.heightAnchor.constraint(equalToConstant: 16),

            previewIconView.centerXAnchor.constraint(
                equalTo: primaryButton.centerXAnchor
            ),
            previewIconView.centerYAnchor.constraint(
                equalTo: primaryButton.centerYAnchor
            ),
            previewIconView.widthAnchor.constraint(equalToConstant: 16),
            previewIconView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    private func setupActions() {
        lightButton.onAction = { [weak self] _ in
            self?.toggleAppearance(.light)
        }
        darkButton.onAction = { [weak self] _ in
            self?.toggleAppearance(.dark)
        }
        primaryButton.onAction = { [weak self] button in
            guard let button = button as? PrimaryButton else {
                return
            }
            self?.onPrimaryChange?(button)
        }
    }
    
    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var orientation: Orientation = .vertical {
        didSet {
            switch orientation {
        case .vertical:
            stackView.orientation = .vertical

            case .horizontal:
                stackView.orientation = .horizontal
            }
        }
    }

    public var viewAppearance: Appearance = .default {
        didSet {
            switch viewAppearance {
            case .vibrant:
                visualEffectView.isHidden = false

            case .default:
                visualEffectView.isHidden = true
            }

            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public weak override var tooltipDelegate: TooltipDelegate? {
        didSet {
            lightButton.tooltipDelegate = tooltipDelegate
            darkButton.tooltipDelegate = tooltipDelegate
            primaryButton.tooltipDelegate = tooltipDelegate
        }
    }

    public var isPrimary: Bool {
        get {
            return primaryButton.isSelected
        }
        set {
            primaryButton.isSelected = newValue
            updateSymbol(
                previewIconView,
                name: "magnifyingglass",
                selected: newValue
            )
        }
    }

    public func setAppearanceType(_ appearanceType: AppearanceType, animated: Bool) {
        self.appearanceType = appearanceType
        let hasLight = appearanceType == .light || appearanceType == .both
        let hasDark = appearanceType == .dark || appearanceType == .both
        updateAppearanceButtons(light: hasLight, dark: hasDark)
    }

    public var onPrimaryChange: GalleryCollectionButtonsView.PrimaryChangeAction?

    public var onAppearanceTypeChange: GalleryCollectionButtonsView.AppearanceTypeChangeAction?
    
    // MARK: - Private
    
    private func stylize() {
        lightButton.style = style?.primaryStyle
        darkButton.style = style?.primaryStyle
        primaryButton.style = style?.primaryStyle
        stackView.borderColor = style?.ownStyle.stackBorderColor

        switch viewAppearance {
        case .vibrant:
            stackView.backgroundColor = style?.ownStyle.stackVibrantBackgroundColor

        case .default:
            stackView.backgroundColor = style?.ownStyle.stackBackgroundColor
        }
    }

    private var appearanceType: AppearanceType = .all

    private func makeAppearanceButton(identifier: String) -> PrimaryButton {
        let button = PrimaryButton()
        button.showTooltip = true
        button.tooltipPresentDelayMilliseconds =
            Constants.tooltipPresentDelayMilliseconds
        button.tooltipIdentifier = identifier
        return button
    }

    private func makeSymbolView(_ name: String) -> NSImageView {
        let imageView = NSImageView()
        let configuration = NSImage.SymbolConfiguration(
            pointSize: 16,
            weight: .regular
        )
        imageView.image = NSImage(
            systemSymbolName: name,
            accessibilityDescription: nil
        )?.withSymbolConfiguration(configuration)
        imageView.image?.isTemplate = true
        imageView.contentTintColor = .tertiaryLabelColor
        imageView.imageScaling = .scaleProportionallyDown
        return imageView
    }

    private func toggleAppearance(_ selected: AppearanceType) {
        let hasLight = appearanceType == .light || appearanceType == .both
        let hasDark = appearanceType == .dark || appearanceType == .both
        var light = hasLight
        var dark = hasDark

        if selected == .light {
            light.toggle()
        } else {
            dark.toggle()
        }

        let newType: AppearanceType
        switch (light, dark) {
        case (false, false): newType = .all
        case (true, false): newType = .light
        case (false, true): newType = .dark
        case (true, true): newType = .both
        }

        appearanceType = newType
        updateAppearanceButtons(light: light, dark: dark)
        onAppearanceTypeChange?(newType)
    }

    private func updateAppearanceButtons(light: Bool, dark: Bool) {
        lightButton.isSelected = light
        darkButton.isSelected = dark
        updateSymbol(lightIconView, name: "sun.max.fill", selected: light)
        updateSymbol(darkIconView, name: "moon.fill", selected: dark)
    }

    private func updateSymbol(
        _ imageView: NSImageView,
        name: String,
        selected: Bool
    ) {
        let configuration = NSImage.SymbolConfiguration(
            pointSize: 16,
            weight: selected ? .bold : .regular
        )
        imageView.image = NSImage(
            systemSymbolName: name,
            accessibilityDescription: nil
        )?.withSymbolConfiguration(configuration)
        imageView.image?.isTemplate = true
        imageView.contentTintColor = selected ? .white : .tertiaryLabelColor
    }
}
