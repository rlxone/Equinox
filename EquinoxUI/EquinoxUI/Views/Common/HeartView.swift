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

extension HeartView {
    private enum Constants {
        static let emissionDuration: TimeInterval = 3
        static let fullCircle: CGFloat = .pi * 2
        static let emissionSpread: CGFloat = .pi * 2
        static let intensity: Float = 0.5
        static let birthRate: Float = 7
        static let lifetime: Float = 5
        static let velocity: CGFloat = 115
        static let velocityRange: CGFloat = 35
        static let spin: CGFloat = 3.5
        static let spinRange: CGFloat = 4
        static let scaleSpeed: CGFloat = -0.1
        static let fadeInDuration: TimeInterval = 0.25
        static let fadeOutDuration: TimeInterval = 0.3
    }
}

public final class HeartView: View {
    private var emitterLayer: CAEmitterLayer?
    private var stopEmissionWorkItem: DispatchWorkItem?
    private var emissionGeneration = 0

    public override init() {
        super.init()
        setup()
    }

    deinit {
        stopEmissionWorkItem?.cancel()
    }

    public override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }

    public var particleImage: NSImage?

    public func spawnHearts() {
        guard particleImage != nil else {
            return
        }

        stopEmissionWorkItem?.cancel()
        emissionGeneration += 1
        let generation = emissionGeneration
        isHidden = false

        layer?.removeAllAnimations()
        alphaValue = 0
        startEmission(emissionLongitude: CGFloat.random(in: 0 ... Constants.fullCircle))

        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constants.fadeInDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animator().alphaValue = 1
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.stopHearts(generation: generation)
        }

        stopEmissionWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.emissionDuration, execute: workItem)
    }

    public override func layout() {
        super.layout()
        updateEmitterGeometry()
    }

    private func setup() {
        wantsLayer = true
        isHidden = true
        alphaValue = 0
    }

    private func stopHearts(generation: Int) {
        guard generation == emissionGeneration else {
            return
        }

        emitterLayer?.birthRate = 0
        NSAnimationContext.runAnimationGroup({ [weak self] context in
            guard let self else {
                return
            }

            context.duration = Constants.fadeOutDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            guard let self, generation == self.emissionGeneration else {
                return
            }

            self.clearEmission()
            self.isHidden = true
        })
    }

    private func startEmission(emissionLongitude: CGFloat) {
        let emitterLayer = emitterLayer ?? makeEmitterLayer()
        emitterLayer.birthRate = 1
        emitterLayer.emitterCells = [makeHeartCell(emissionLongitude: emissionLongitude)]

        if emitterLayer.superlayer == nil {
            layer?.addSublayer(emitterLayer)
        }

        self.emitterLayer = emitterLayer
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

        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitterLayer.emitterSize = .zero
    }

    private func makeHeartCell(emissionLongitude: CGFloat) -> CAEmitterCell {
        let resolvedIntensity = max(0, Constants.intensity)
        let cell = CAEmitterCell()

        cell.birthRate = Constants.birthRate * resolvedIntensity
        cell.lifetime = Constants.lifetime * resolvedIntensity
        cell.color = NSColor.systemRed.cgColor
        cell.velocity = Constants.velocity * CGFloat(resolvedIntensity)
        cell.velocityRange = Constants.velocityRange * CGFloat(resolvedIntensity)
        cell.emissionLongitude = emissionLongitude
        cell.emissionRange = Constants.emissionSpread
        cell.spin = Constants.spin * CGFloat(resolvedIntensity)
        cell.spinRange = Constants.spinRange * CGFloat(resolvedIntensity)
        cell.scaleRange = CGFloat(resolvedIntensity)
        cell.scaleSpeed = Constants.scaleSpeed * CGFloat(resolvedIntensity)
        cell.contents = particleImage?.cgImage(forProposedRect: nil, context: nil, hints: nil)

        return cell
    }

    private func clearEmission() {
        emitterLayer?.birthRate = 0
        emitterLayer?.emitterCells = nil
        emitterLayer?.removeFromSuperlayer()
        emitterLayer = nil
    }
}
