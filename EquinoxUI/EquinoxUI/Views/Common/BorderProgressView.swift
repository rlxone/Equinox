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

extension BorderProgressView {
    private enum Constants {
        static let shadowRadius: CGFloat = 10
        static let shadowOpacity: Float = 1
    }
}

public final class BorderProgressView: View {
    private lazy var borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineCap = .round
        layer.fillColor = nil
        layer.strokeStart = 0
        layer.shadowRadius = Constants.shadowRadius
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowOffset = .zero
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
        borderLayer.frame = bounds
        borderLayer.path = roundedLinePath
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
    }

    private func setupView() {
        wantsLayer = true
        layer?.masksToBounds = false
        layer?.addSublayer(borderLayer)
    }

    // MARK: - Public

    public var radius: CGFloat = 0 {
        didSet {
            needsLayout = true
        }
    }

    public var lineWidth: CGFloat = 0 {
        didSet {
            needsLayout = true
            borderLayer.lineWidth = lineWidth
        }
    }

    public func setProgress(_ progress: Float, animated: Bool) {
        if animated {
            self.progress = progress
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.progress = progress
            CATransaction.commit()
        }
    }

    public var strokeColor: NSColor? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    // MARK: - Private

    private var progress: Float = 0 {
        didSet {
            borderLayer.strokeEnd = CGFloat(progress)
            needsLayout = true
        }
    }

    private var roundedLinePath: CGPath {
        let path = CGMutablePath()
        path.move(to: .init(
            x: bounds.midX,
            y: bounds.maxY
        ))
        path.addLine(to: .init(
            x: bounds.maxX - radius,
            y: bounds.maxY
        ))
        path.addArc(
            center: .init(
                x: bounds.maxX - radius,
                y: bounds.maxY - radius
            ),
            radius: radius,
            startAngle: .pi / 2,
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: .init(
            x: bounds.maxX,
            y: radius
        ))
        path.addArc(
            center: .init(
                x: bounds.maxX - radius,
                y: radius
            ),
            radius: radius,
            startAngle: 0,
            endAngle: -.pi / 2,
            clockwise: true
        )
        path.addLine(to: .init(
            x: radius,
            y: 0
        ))
        path.addArc(
            center: .init(
                x: radius,
                y: radius
            ),
            radius: radius,
            startAngle: 3 * .pi / 2,
            endAngle: .pi,
            clockwise: true
        )
        path.addLine(to: .init(
            x: 0,
            y: bounds.maxY - radius
        ))
        path.addArc(
            center: .init(
                x: radius,
                y: bounds.maxY - radius
            ),
            radius: radius,
            startAngle: .pi,
            endAngle: .pi / 2,
            clockwise: true
        )
        path.closeSubpath()
        return path
    }

    private func stylize() {
        borderLayer.strokeColor = strokeColor?.cgColor
        borderLayer.shadowColor = strokeColor?.cgColor
    }
}
