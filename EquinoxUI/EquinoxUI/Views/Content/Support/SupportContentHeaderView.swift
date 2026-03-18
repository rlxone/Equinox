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

final class SupportContentHeaderView: View {
    private enum Constants {
        static let animatedImageAnimationDuration: TimeInterval = 3
        static let gradientMaskLocations: [NSNumber] = [0.0, 1.0]
        static let gradientMaskStartPoint = CGPoint(x: 0.5, y: 0.0)
        static let gradientMaskEndPoint = CGPoint(x: 0.5, y: 1.0)
        static let gradientMaskCornerRadius: CGFloat = 0
    }

    private lazy var animatedImageView = AnimatedImageView(animationDuration: Constants.animatedImageAnimationDuration)

    private lazy var gradientMask: CAGradientLayer = {
        let gradientMask = CAGradientLayer()
        gradientMask.colors = [
            NSColor.clear.cgColor,
            NSColor.black.cgColor
        ]
        gradientMask.locations = Constants.gradientMaskLocations
        gradientMask.startPoint = Constants.gradientMaskStartPoint
        gradientMask.endPoint = Constants.gradientMaskEndPoint
        return gradientMask
    }()

    private lazy var gradientMaskShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = NSColor.black.cgColor
        return shapeLayer
    }()

    // MARK: - Initializer

    override init() {
        super.init()
        setup()
    }

    // MARK: - Life Cycle

    public override func layout() {
        super.layout()
        updateMask()
    }

    // MARK: - Setup

    private func setup() {
        wantsLayer = true
        addSubview(animatedImageView)
        setupConstraints()
    }

    private func setupConstraints() {
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animatedImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animatedImageView.topAnchor.constraint(equalTo: topAnchor),
            animatedImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animatedImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public

    weak var animatedImageDelegate: AnimatedImageViewDelegate? {
        didSet {
            animatedImageView.delegate = animatedImageDelegate
        }
    }

    func beginAnimation() {
        animatedImageView.beginAnimation()
    }

    // MARK: - Private

    private func updateMask() {
        gradientMask.frame = bounds
        gradientMaskShapeLayer.frame = bounds
        gradientMaskShapeLayer.path = NSBezierPath(
            roundedRect: bounds,
            xRadius: Constants.gradientMaskCornerRadius,
            yRadius: Constants.gradientMaskCornerRadius
        ).path
        gradientMask.mask = gradientMaskShapeLayer
        layer?.mask = gradientMask
    }
}
