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

extension CreateAnimatedImageView {
    public struct Style {
        let progressColor: NSColor
        let borderColor: NSColor

        public init(progressColor: NSColor, borderColor: NSColor) {
            self.progressColor = progressColor
            self.borderColor = borderColor
        }
    }

    private enum Constants {
        static let borderAnimationDuration: TimeInterval = 0.3
    }
}

// MARK: - Class

public final class CreateAnimatedImageView: View {
    private lazy var animatedImageView = DragAnimatedImageView()

    private lazy var borderView: BorderProgressView = {
        let view = BorderProgressView()
        view.setProgress(1, animated: false)
        return view
    }()

    private lazy var progressView: BorderProgressView = {
        let view = BorderProgressView()
        view.setProgress(0, animated: false)
        return view
    }()

    private var progressLeadingConstraint: NSLayoutConstraint?
    private var progressTopConstraint: NSLayoutConstraint?
    private var progressTrailingConstraint: NSLayoutConstraint?
    private var progressBottomConstraint: NSLayoutConstraint?

    private var borderLeadingConstraint: NSLayoutConstraint?
    private var borderTopConstraint: NSLayoutConstraint?
    private var borderTrailingConstraint: NSLayoutConstraint?
    private var borderBottomConstraint: NSLayoutConstraint?

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
    }

    private func setupView() {
        wantsLayer = true
        layer?.masksToBounds = false

        addSubview(animatedImageView)
        addSubview(borderView)
        addSubview(progressView)
    }

    private func setupConstraints() {
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        borderView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animatedImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animatedImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animatedImageView.topAnchor.constraint(equalTo: topAnchor),
            animatedImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        borderLeadingConstraint = borderView.leadingAnchor.constraint(equalTo: animatedImageView.leadingAnchor)
        borderTopConstraint = borderView.topAnchor.constraint(equalTo: animatedImageView.topAnchor)
        borderTrailingConstraint = borderView.trailingAnchor.constraint(equalTo: animatedImageView.trailingAnchor)
        borderBottomConstraint = borderView.bottomAnchor.constraint(equalTo: animatedImageView.bottomAnchor)

        progressLeadingConstraint = progressView.leadingAnchor.constraint(equalTo: animatedImageView.leadingAnchor)
        progressTopConstraint = progressView.topAnchor.constraint(equalTo: animatedImageView.topAnchor)
        progressTrailingConstraint = progressView.trailingAnchor.constraint(equalTo: animatedImageView.trailingAnchor)
        progressBottomConstraint = progressView.bottomAnchor.constraint(equalTo: animatedImageView.bottomAnchor)

        borderLeadingConstraint?.isActive = true
        borderTopConstraint?.isActive = true
        borderTrailingConstraint?.isActive = true
        borderBottomConstraint?.isActive = true

        progressLeadingConstraint?.isActive = true
        progressTopConstraint?.isActive = true
        progressTrailingConstraint?.isActive = true
        progressBottomConstraint?.isActive = true
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public weak var delegate: AnimatedImageViewDelegate? {
        didSet {
            animatedImageView.delegate = delegate
        }
    }

    public weak var dragDelegate: DragAnimatedImageViewDelegate? {
        didSet {
            animatedImageView.dragDelegate = dragDelegate
        }
    }

    public var cornerRadius: CGFloat = 0 {
        didSet {
            animatedImageView.cornerRadius = cornerRadius
        }
    }

    public var borderCornerRadius: CGFloat = 0 {
        didSet {
            borderView.radius = borderCornerRadius
        }
    }

    public var progressCornerRadius: CGFloat = 0 {
        didSet {
            progressView.radius = progressCornerRadius
        }
    }

    public var lineWidth: CGFloat = 0 {
        didSet {
            borderView.lineWidth = lineWidth
            progressView.lineWidth = lineWidth
        }
    }

    public var isProgressHidden: Bool {
        get {
            return progressView.isHidden
        }
        set {
            progressView.isHidden = newValue
        }
    }

    public func beginAnimation() {
        animatedImageView.beginAnimation()
    }

    public func setProgress(_ progress: Float, animated: Bool) {
        progressView.setProgress(progress, animated: animated)
    }

    public func setBorderOffset(_ offset: CGFloat, animated: Bool) {
        let changes: () -> Void = { [weak self] in
            self?.borderTopConstraint?.constant = -offset
            self?.borderLeadingConstraint?.constant = -offset
            self?.borderTrailingConstraint?.constant = offset
            self?.borderBottomConstraint?.constant = offset

            self?.progressTopConstraint?.constant = -offset
            self?.progressLeadingConstraint?.constant = -offset
            self?.progressTrailingConstraint?.constant = offset
            self?.progressBottomConstraint?.constant = offset
        }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = Constants.borderAnimationDuration
                context.timingFunction = .init(name: .easeInEaseOut)
                context.allowsImplicitAnimation = true

                changes()
            }
        } else {
            changes()
        }
    }

    // MARK: - Private

    private func stylize() {
        borderView.strokeColor = style?.borderColor
        progressView.strokeColor = style?.progressColor
    }
}
