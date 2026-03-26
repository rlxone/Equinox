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

extension SupportAvatarView {
    private enum Constants {
        static let interactionAnimationDuration: TimeInterval = 0.2
        static let pressedScale: CGFloat = 0.9
        static let releasedScale: CGFloat = 1
        static let glassCornerRadius: CGFloat = 75
        static let avatarImageCornerRadius: CGFloat = 64
        static let transformKeyPath = "transform"
        static let scaleAnimationKey = "support.avatar.scale"
        static let transformIdentityComponent: CGFloat = 1
        static let transformZeroComponent: CGFloat = 0
    }
}

final class SupportAvatarView: View {
    private lazy var glassAvatarContainerView: GlassView = {
        let glassView = GlassView(style: .regular, fallbackVisualEffect: (.hudWindow, .withinWindow))
        glassView.wantsLayer = true
        glassView.cornerRadius = Constants.glassCornerRadius
        return glassView
    }()
    
    private lazy var avatarImageView: ImageView = {
        let imageView = ImageView()
        imageView.wantsLayer = true
        imageView.layer?.cornerRadius = Constants.avatarImageCornerRadius
        return imageView
    }()
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        setup()
    }
    
    // MARK: - Life Cycle
    
    public override func mouseDown(with event: NSEvent) {
        guard isUserInteractionsEnabled else {
            super.mouseDown(with: event)
            return
        }

        animateScale(scale: Constants.pressedScale)
        super.mouseDown(with: event)
    }

    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        guard isUserInteractionsEnabled else {
            return
        }

        animateScale(scale: Constants.releasedScale)
        guard isPointInsideView(for: event) else {
            return
        }

        action?()
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupView()
        setupConstraints()
    }
    
    private func setupView() {
        wantsLayer = true
        addSubview(glassAvatarContainerView)
        glassAvatarContainerView.contentView.addSubview(avatarImageView)
    }
    
    private func setupConstraints() {
        glassAvatarContainerView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            glassAvatarContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassAvatarContainerView.topAnchor.constraint(equalTo: topAnchor),
            glassAvatarContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassAvatarContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            avatarImageView.centerXAnchor.constraint(equalTo: glassAvatarContainerView.contentView.centerXAnchor),
            avatarImageView.centerYAnchor.constraint(equalTo: glassAvatarContainerView.contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Public
    
    var image: NSImage? {
        get {
            avatarImageView.image
        }
        set {
            avatarImageView.image = newValue
        }
    }

    var action: (() -> Void)?
    
    // MARK: - Private
    
    private func animateScale(scale: CGFloat) {
        guard let layer = layer else {
            return
        }
        
        let targetTransform = centeredScaleTransform(scale: scale)
        let animation = CABasicAnimation(keyPath: Constants.transformKeyPath)
        animation.fromValue = layer.presentation()?.transform ?? layer.transform
        animation.toValue = targetTransform
        animation.duration = Constants.interactionAnimationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        layer.add(animation, forKey: Constants.scaleAnimationKey)
        layer.transform = targetTransform
    }

    private func centeredScaleTransform(scale: CGFloat) -> CATransform3D {
        let xOffset = bounds.midX * (Constants.transformIdentityComponent - scale)
        let yOffset = bounds.midY * (Constants.transformIdentityComponent - scale)
        let transform = CGAffineTransform(
            a: scale,
            b: Constants.transformZeroComponent,
            c: Constants.transformZeroComponent,
            d: scale,
            tx: xOffset,
            ty: yOffset
        )
        return CATransform3DMakeAffineTransform(transform)
    }

    private func isPointInsideView(for event: NSEvent) -> Bool {
        let location = convert(event.locationInWindow, from: nil)
        return bounds.contains(location)
    }
}
