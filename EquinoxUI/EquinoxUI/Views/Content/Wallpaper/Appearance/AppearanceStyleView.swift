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

extension AppearanceStyleView {
    public struct Style {
        let lightColor: NSColor
        let darkColor: NSColor
        let borderColor: NSColor

        public init(lightColor: NSColor, darkColor: NSColor, borderColor: NSColor) {
            self.lightColor = lightColor
            self.darkColor = darkColor
            self.borderColor = borderColor
        }
    }

    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let leftLocation: [NSNumber] = [0, 0]
        static let centerLocation: [NSNumber] = [0.5, 0.5]
        static let rightLocation: [NSNumber] = [1, 1]
        static let startPoint = CGPoint(x: 0, y: 0.5)
        static let endPoint = CGPoint(x: 1, y: 0.5)
    }
}

// MARK: - Class

public final class AppearanceStyleView: View {
    private lazy var outerGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = Constants.centerLocation
        layer.startPoint = Constants.startPoint
        layer.endPoint = Constants.endPoint
        return layer
    }()

    private lazy var innerGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.locations = Constants.centerLocation
        layer.startPoint = Constants.startPoint
        layer.endPoint = Constants.endPoint
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
        outerGradientLayer.frame = bounds
        innerGradientLayer.frame = .init(
            x: bounds.width / 4,
            y: bounds.width / 4,
            width: bounds.width / 2,
            height: bounds.width / 2
        )
        layer?.cornerRadius = bounds.height / 2
        innerGradientLayer.cornerRadius = bounds.height / 4
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
        setupGradientLayers()
    }

    private func setupView() {
        wantsLayer = true
        layer?.borderWidth = Constants.borderWidth
    }

    private func setupGradientLayers() {
        layer?.addSublayer(outerGradientLayer)
        layer?.addSublayer(innerGradientLayer)
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var type: AppearanceType = .all {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)

            switch type {
            case .all:
                outerGradientLayer.locations = Constants.centerLocation
                innerGradientLayer.locations = Constants.centerLocation

            case .light:
                outerGradientLayer.locations = Constants.rightLocation
                innerGradientLayer.locations = Constants.rightLocation

            case .dark:
                outerGradientLayer.locations = Constants.leftLocation
                innerGradientLayer.locations = Constants.leftLocation
            }

            CATransaction.commit()
        }
    }

    // MARK: - Private

    private func stylize() {
        outerGradientLayer.colors = [
            style?.lightColor.cgColor ?? .white,
            style?.darkColor.cgColor ?? .black
        ]
        innerGradientLayer.colors = [
            style?.darkColor.cgColor ?? .black,
            style?.lightColor.cgColor ?? .white
        ]
        layer?.borderColor = style?.borderColor.cgColor
    }
}
