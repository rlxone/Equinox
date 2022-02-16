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

// MARK: - Protocols

public protocol AnimatedImageViewDelegate: AnyObject {
    func numberOfImages() -> Int
    func image(for index: Int, initial: Bool, completion: @escaping (NSImage?) -> Void)
}

// MARK: - Enums, Structs

extension AnimatedImageView {
    private enum Constants {
        static let animationDuration: TimeInterval = 1.5
    }
}
 
// MARK: - Class

public class AnimatedImageView: View {
    private var initial = true
    
    private lazy var foregroundImageView: ImageView = {
        let imageView = ImageView()
        imageView.imageContentsGravity = .resizeAspectFill
        return imageView
    }()

    private lazy var backgroundImageView: ImageView = {
        let imageView = ImageView()
        imageView.imageContentsGravity = .resizeAspectFill
        return imageView
    }()

    private lazy var maskedLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.anchorPoint = .zero
        return layer
    }()

    private var currentIndex = 0

    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }

    // MARK: - Setup

    public override func layout() {
        super.layout()
        maskedLayer.bounds = bounds
        maskedLayer.path = .init(
            roundedRect: bounds,
            cornerWidth: cornerRadius,
            cornerHeight: cornerRadius,
            transform: nil
        )
        layer?.mask = maskedLayer
    }

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        wantsLayer = true

        addSubview(backgroundImageView)
        addSubview(foregroundImageView)
    }

    private func setupConstraints() {
        foregroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            foregroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            foregroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            foregroundImageView.topAnchor.constraint(equalTo: topAnchor),
            foregroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public
    
    public weak var delegate: AnimatedImageViewDelegate?
    
    public var cornerRadius: CGFloat = 0 {
        didSet {
            needsLayout = true
        }
    }
    
    public func beginAnimation() {
        currentIndex = 0
        startAnimation()
    }
    
    public var isEnabled: Bool {
        return foregroundImageView.isEnabled && backgroundImageView.isEnabled
    }
    
    // MARK: - Private
    
    private func startAnimation() {
        guard let numberOfImages = delegate?.numberOfImages(), numberOfImages > 0 else {
            return
        }
        
        let foregroundImageIndex = currentIndex
        let backgroundImageIndex = currentIndex == numberOfImages - 1 ? 0 : currentIndex + 1
        
        foregroundImageView.image = nil
        
        delegate?.image(for: foregroundImageIndex, initial: initial) { [weak self] image in
            self?.foregroundImageView.image = image
        }
        
        delegate?.image(for: backgroundImageIndex, initial: initial) { [weak self] image in
            self?.backgroundImageView.image = image
        }
        
        if initial {
            initial = false
        }
        
        animateTransition { [weak self] in
            if self?.currentIndex == numberOfImages - 1 {
                self?.currentIndex = 0
            } else {
                self?.currentIndex += 1
            }
            self?.startAnimation()
        }
    }
    
    private func animateTransition(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = Constants.animationDuration
        animation.timingFunction = .init(name: .easeInEaseOut)
        foregroundImageView.layer?.add(animation, forKey: nil)
        foregroundImageView.layer?.opacity = 0
        
        CATransaction.commit()
    }
}
