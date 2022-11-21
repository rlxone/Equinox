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

extension CreateContentView {
    public enum AnimationResult {
        case success
        case failure
    }

    public struct Style {
        public struct OwnStyle {
            let overlayBackgroundColor: NSColor
            let overlayBorderColor: NSColor

            public init(
                overlayBackgroundColor: NSColor,
                overlayBorderColor: NSColor
            ) {
                self.overlayBackgroundColor = overlayBackgroundColor
                self.overlayBorderColor = overlayBorderColor
            }
        }

        let ownStyle: OwnStyle
        let headerStyle: CreateHeaderView.Style
        let animatedImageStyle: CreateAnimatedImageView.Style
        let bottomStyle: CreateBottomView.Style

        public init(
            ownStyle: OwnStyle,
            headerStyle: CreateHeaderView.Style,
            animatedImageStyle: CreateAnimatedImageView.Style,
            bottomStyle: CreateBottomView.Style
        ) {
            self.ownStyle = ownStyle
            self.headerStyle = headerStyle
            self.animatedImageStyle = animatedImageStyle
            self.bottomStyle = bottomStyle
        }
    }

    private enum Constants {
        static let overlayCornerRadius: CGFloat = 16
        static let overlayBorderWidth: CGFloat = 1
        static let imageCornerRadius: CGFloat = 8
        static let compactHeight: CGFloat = 330
        static let regularHeight: CGFloat = 546
        static let headerViewTopOffset: CGFloat = 40
        static let animatedImageViewWidth: CGFloat = 360
        static let animatedImageLeadingOffset: CGFloat = 64
        static let animatedImageTrailingOffset: CGFloat = 64
        static let shadowAnimatedImageViewWidth: CGFloat = 420
        static let imageWidthMultiplier: CGFloat = 9 / 16
        static let borderOffset: CGFloat = 0.5
        static let progressOffset: CGFloat = 1.5
        static let borderCornerRadius: CGFloat = 9
        static let progressLineWidth: CGFloat = 3
        static let borderLineWidth: CGFloat = 1
        static let completeContraintAnimationDuration: TimeInterval = 0.3
        static let animatedImageViewCenterYOffset: CGFloat = 43
    }
}

// MARK: - Class

public final class CreateContentView: View {
    private lazy var backgroundView: VisualEffectView = {
        let view = VisualEffectView(material: .windowBackground, blendingMode: .behindWindow)
        view.alphaValue = 0
        view.isUserInteractionsEnabled = false
        return view
    }()

    private lazy var overlayView: VisualEffectView = {
        let visualEffectView = VisualEffectView(material: .headerView, blendingMode: .withinWindow)
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = Constants.overlayCornerRadius
        visualEffectView.layer?.borderWidth = Constants.overlayBorderWidth
        return visualEffectView
    }()

    private lazy var shadowOverlayView = VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)

    private lazy var headerView: CreateHeaderView = {
        let view = CreateHeaderView()
        view.alphaValue = 0
        return view
    }()

    private lazy var bottomView: CreateBottomView = {
        let view = CreateBottomView()
        view.alphaValue = 0
        return view
    }()

    private lazy var animatedImageView: CreateAnimatedImageView = {
        let imageView = CreateAnimatedImageView()
        imageView.cornerRadius = Constants.imageCornerRadius
        imageView.borderCornerRadius = Constants.borderCornerRadius
        imageView.progressCornerRadius = Constants.borderCornerRadius
        imageView.lineWidth = Constants.progressLineWidth
        imageView.setBorderOffset(Constants.progressOffset, animated: false)
        return imageView
    }()

    private lazy var shadowAnimatedImageView: AnimatedImageView = {
        let view = AnimatedImageView()
        view.cornerRadius = Constants.imageCornerRadius
        return view
    }()

    private var animatedImageCenterYConstraint: NSLayoutConstraint?
    private var shadowAnimatedImageCenterYConstraint: NSLayoutConstraint?
    private var overlayHeightConstraint: NSLayoutConstraint?

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

        addSubview(backgroundView)
        addSubview(overlayView)

        overlayView.contentView.addSubview(shadowAnimatedImageView)
        overlayView.contentView.addSubview(shadowOverlayView)
        overlayView.contentView.addSubview(headerView)
        overlayView.contentView.addSubview(bottomView)
        overlayView.contentView.addSubview(animatedImageView)
    }

    private func setupConstraints() {
        setupOverlayConstraints()
        setupHeaderConstraints()
        setupImageConstraints()
        setupBottomConstraints()
    }

    private func setupOverlayConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        shadowOverlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),

            overlayView.centerXAnchor.constraint(equalTo: centerXAnchor),
            overlayView.centerYAnchor.constraint(equalTo: centerYAnchor),

            shadowOverlayView.topAnchor.constraint(equalTo: overlayView.contentView.topAnchor),
            shadowOverlayView.leadingAnchor.constraint(equalTo: overlayView.contentView.leadingAnchor),
            shadowOverlayView.trailingAnchor.constraint(equalTo: overlayView.contentView.trailingAnchor),
            shadowOverlayView.bottomAnchor.constraint(equalTo: overlayView.contentView.bottomAnchor)
        ])

        overlayHeightConstraint = overlayView.heightAnchor.constraint(equalToConstant: Constants.compactHeight)
        overlayHeightConstraint?.isActive = true
    }

    private func setupHeaderConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: overlayView.contentView.topAnchor, constant: Constants.headerViewTopOffset),
            headerView.leadingAnchor.constraint(equalTo: overlayView.contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: overlayView.contentView.trailingAnchor)
        ])
    }

    private func setupImageConstraints() {
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        shadowAnimatedImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            animatedImageView.widthAnchor.constraint(equalToConstant: Constants.animatedImageViewWidth),
            animatedImageView.heightAnchor.constraint(equalTo: animatedImageView.widthAnchor, multiplier: Constants.imageWidthMultiplier),
            animatedImageView.centerXAnchor.constraint(equalTo: overlayView.contentView.centerXAnchor),
            animatedImageView.leadingAnchor.constraint(
                equalTo: overlayView.contentView.leadingAnchor,
                constant: Constants.animatedImageLeadingOffset
            ),
            animatedImageView.trailingAnchor.constraint(
                equalTo: overlayView.contentView.trailingAnchor,
                constant: -Constants.animatedImageTrailingOffset
            ),
            shadowAnimatedImageView.widthAnchor.constraint(equalToConstant: Constants.shadowAnimatedImageViewWidth),
            shadowAnimatedImageView.heightAnchor.constraint(equalTo: shadowAnimatedImageView.widthAnchor, multiplier: Constants.imageWidthMultiplier),
            shadowAnimatedImageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        animatedImageCenterYConstraint = animatedImageView.centerYAnchor.constraint(equalTo: overlayView.contentView.centerYAnchor)
        shadowAnimatedImageCenterYConstraint = shadowAnimatedImageView.centerYAnchor.constraint(equalTo: animatedImageView.centerYAnchor)
        animatedImageCenterYConstraint?.isActive = true
        shadowAnimatedImageCenterYConstraint?.isActive = true
    }

    private func setupBottomConstraints() {
        bottomView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: overlayView.contentView.bottomAnchor),
            bottomView.trailingAnchor.constraint(equalTo: overlayView.contentView.trailingAnchor),
            bottomView.leadingAnchor.constraint(equalTo: overlayView.contentView.leadingAnchor)
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var statusText: String? {
        didSet {
            headerView.statusText = statusText
        }
    }

    public var descriptionText: String? {
        didSet {
            headerView.descriptionText = descriptionText
        }
    }

    public var saveButtonTitle: String? {
        didSet {
            bottomView.saveButtonTitle = saveButtonTitle
        }
    }

    public var setButtonTitle: String? {
        didSet {
            bottomView.setButtonTitle = setButtonTitle
        }
    }

    public var createButtonTitle: String? {
        didSet {
            bottomView.createButtonTitle = createButtonTitle
        }
    }

    public var cancelButtonTitle: String? {
        didSet {
            bottomView.cancelButtonTitle = cancelButtonTitle
        }
    }

    public var shareButtonTitle: String? {
        didSet {
            bottomView.shareButtonTitle = shareButtonTitle
        }
    }

    public var cancelButtonAction: Button.Action? {
        didSet {
            bottomView.cancelButtonAction = cancelButtonAction
        }
    }

    public var saveButtonAction: Button.Action? {
        didSet {
            bottomView.saveButtonAction = saveButtonAction
        }
    }

    public var setButtonAction: Button.Action? {
        didSet {
            bottomView.setButtonAction = setButtonAction
        }
    }

    public var createButtonAction: Button.Action? {
        didSet {
            bottomView.createButtonAction = createButtonAction
        }
    }

    public var shareButtonAction: Button.Action? {
        didSet {
            bottomView.shareButtonAction = shareButtonAction
        }
    }

    public weak var animatedImageDelegate: AnimatedImageViewDelegate? {
        didSet {
            animatedImageView.delegate = animatedImageDelegate
            shadowAnimatedImageView.delegate = animatedImageDelegate
        }
    }

    public weak var dragAnimatedImageDelegate: DragAnimatedImageViewDelegate? {
        didSet {
            animatedImageView.dragDelegate = dragAnimatedImageDelegate
        }
    }

    public var isProgressHidden: Bool {
        get {
            return animatedImageView.isProgressHidden
        }
        set {
            animatedImageView.isProgressHidden = newValue
        }
    }

    public var tags: [String] = [] {
        didSet {
            bottomView.tags = tags
        }
    }

    public func setProgress(_ progress: Float, animated: Bool) {
        animatedImageView.setProgress(progress, animated: animated)
    }

    public func startProcessAnimation() {
        animatedImageView.beginAnimation()
        shadowAnimatedImageView.beginAnimation()
    }

    public func completeProcessAnimation(with reason: AnimationResult) {
        animatedImageView.lineWidth = Constants.borderLineWidth
        animatedImageView.setBorderOffset(Constants.borderOffset, animated: true)

        bottomView.showButtons(success: reason == .success)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = Constants.completeContraintAnimationDuration
            context.timingFunction = .init(name: .easeInEaseOut)

            self.animatedImageCenterYConstraint?.animator().constant = -Constants.animatedImageViewCenterYOffset
            self.overlayHeightConstraint?.animator().constant = Constants.regularHeight

            self.headerView.animator().alphaValue = 1
            self.bottomView.animator().alphaValue = 1
        }, completionHandler: nil)
    }

    // MARK: - Private

    private func stylize() {
        layer?.backgroundColor = style?.ownStyle.overlayBackgroundColor.cgColor
        overlayView.layer?.borderColor = style?.ownStyle.overlayBorderColor.cgColor
        animatedImageView.style = style?.animatedImageStyle

        headerView.style = style?.headerStyle
        bottomView.style = style?.bottomStyle
    }
}
