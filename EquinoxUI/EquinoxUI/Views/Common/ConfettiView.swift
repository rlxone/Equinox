// Copyright (c) 2026 Dzmitry Miadziukha
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
import QuartzCore

extension ConfettiView {
    private enum Constants {
        static let intensity: Float = 0.4
        static let emitterHeight: CGFloat = 1

        static let birthRate: Float = 6
        static let lifetime: Float = 14
        static let velocity: CGFloat = 350
        static let velocityRange: CGFloat = 80
        static let spin: CGFloat = 3.5
        static let spinRange: CGFloat = 4
        static let scaleSpeed: CGFloat = -0.1

        static let defaultColors: [NSColor] = [
            NSColor(red: 0.95, green: 0.40, blue: 0.27, alpha: 1),
            NSColor(red: 1.00, green: 0.78, blue: 0.36, alpha: 1),
            NSColor(red: 0.48, green: 0.78, blue: 0.64, alpha: 1),
            NSColor(red: 0.30, green: 0.76, blue: 0.85, alpha: 1),
            NSColor(red: 0.58, green: 0.39, blue: 0.55, alpha: 1)
        ]
    }
}

public final class ConfettiView: NSView {
    private var emitterLayer: CAEmitterLayer?

    public var particleImage: NSImage? {
        didSet {
            reloadEmitterCellsIfNeeded()
        }
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layout() {
        super.layout()
        updateEmitterGeometry()
    }

    public func startConfetti() {
        guard particleImage != nil else {
            return
        }

        let emitterLayer = emitterLayer ?? makeEmitterLayer()
        emitterLayer.birthRate = 1
        emitterLayer.emitterCells = Constants.defaultColors.map(makeConfettiCell(color:))

        if emitterLayer.superlayer == nil {
            layer?.addSublayer(emitterLayer)
        }

        self.emitterLayer = emitterLayer
    }

    public func stopConfetti() {
        emitterLayer?.birthRate = 0
    }

    private func makeEmitterLayer() -> CAEmitterLayer {
        let layer = CAEmitterLayer()
        layer.emitterShape = .point
        updateEmitterGeometry(layer)
        return layer
    }

    private func updateEmitterGeometry(_ emitterLayer: CAEmitterLayer? = nil) {
        guard let emitterLayer = emitterLayer ?? self.emitterLayer else {
            return
        }

        let yPosition = isFlipped ? 0 : bounds.maxY
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: yPosition)
        emitterLayer.emitterSize = CGSize(width: bounds.width, height: Constants.emitterHeight)
    }

    private func reloadEmitterCellsIfNeeded() {
        guard let emitterLayer else {
            return
        }

        emitterLayer.emitterCells = Constants.defaultColors.map(makeConfettiCell(color:))
    }

    private func makeConfettiCell(color: NSColor) -> CAEmitterCell {
        let resolvedIntensity = max(0, Constants.intensity)
        let cell = CAEmitterCell()

        cell.birthRate = Constants.birthRate * resolvedIntensity
        cell.lifetime = Constants.lifetime * resolvedIntensity
        cell.color = color.cgColor
        cell.velocity = Constants.velocity * CGFloat(resolvedIntensity)
        cell.velocityRange = Constants.velocityRange * CGFloat(resolvedIntensity)
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi * 2
        cell.spin = Constants.spin * CGFloat(resolvedIntensity)
        cell.spinRange = Constants.spinRange * CGFloat(resolvedIntensity)
        cell.scaleRange = CGFloat(resolvedIntensity)
        cell.scaleSpeed = Constants.scaleSpeed * CGFloat(resolvedIntensity)
        cell.contents = particleImage?.cgImage(forProposedRect: nil, context: nil, hints: nil)

        return cell
    }
}
