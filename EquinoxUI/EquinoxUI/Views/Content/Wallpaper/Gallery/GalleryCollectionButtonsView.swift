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
    public typealias AppearanceTypeChangeAction = (DynamicButton) -> Void

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
        static let cornerRadius: CGFloat = 4
        static let borderWidth: CGFloat = 1
        static let buttonSize: CGFloat = 24
        static let tooltipPresentDelayMilliseconds = 1_000
    }
}

// MARK: - Class

public final class GalleryCollectionButtonsView: View {
    private lazy var dynamicButton: DynamicButton = {
        let button = DynamicButton()
        button.showTooltip = true
        button.tooltipPresentDelayMilliseconds = Constants.tooltipPresentDelayMilliseconds
        button.tooltipIdentifier = GalleryContentView.TooltipIdentifier.appearance.rawValue
        return button
    }()
    private lazy var primaryButton: PrimaryButton = {
        let button = PrimaryButton()
        button.showTooltip = true
        button.tooltipPresentDelayMilliseconds = Constants.tooltipPresentDelayMilliseconds
        button.tooltipIdentifier = GalleryContentView.TooltipIdentifier.primary.rawValue
        return button
    }()

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
        return stackView
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
    
    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
        setupActions()
    }

    private func setupView() {
        addSubview(visualEffectView)
        addSubview(stackView)

        visualEffectView.isHidden = true

        stackView.addView(dynamicButton, in: .center)
        stackView.addView(primaryButton, in: .center)
    }

    private func setupConstraints() {
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        dynamicButton.translatesAutoresizingMaskIntoConstraints = false
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

            primaryButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            primaryButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),

            dynamicButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            dynamicButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }

    private func setupActions() {
        dynamicButton.onAction = { [weak self] button in
            guard let button = button as? DynamicButton else {
                return
            }
            self?.onAppearanceTypeChange?(button)
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
            dynamicButton.tooltipDelegate = tooltipDelegate
            primaryButton.tooltipDelegate = tooltipDelegate
        }
    }

    public var isPrimary: Bool {
        get {
            return primaryButton.isSelected
        }
        set {
            primaryButton.isSelected = newValue
        }
    }

    public func setAppearanceType(_ appearanceType: AppearanceType, animated: Bool) {
        dynamicButton.setType(appearanceType, animated: animated)
    }

    public func getAppearanceType() -> AppearanceType {
        return dynamicButton.getType()
    }

    public var onPrimaryChange: GalleryCollectionButtonsView.PrimaryChangeAction?

    public var onAppearanceTypeChange: GalleryCollectionButtonsView.AppearanceTypeChangeAction?
    
    // MARK: - Private
    
    private func stylize() {
        dynamicButton.style = style?.dynamicStyle
        primaryButton.style = style?.primaryStyle

        stackView.borderColor = style?.ownStyle.stackBorderColor

        switch viewAppearance {
        case .vibrant:
            stackView.backgroundColor = style?.ownStyle.stackVibrantBackgroundColor

        case .default:
            stackView.backgroundColor = style?.ownStyle.stackBackgroundColor
        }
    }
}
