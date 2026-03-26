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

// MARK: - Enums, Structs

extension SupportContentView {
    public typealias OptionAction = (Option) -> Void

    public struct Style {
        let optionsStyle: SupportOptionView.Style
        let lineStyle: LineView.Style
        let titleStyle: StyledLabel.Style
        let descriptionStyle: StyledLabel.Style
        let closeButtonStyle: PushButton.Style

        public init(
            optionsStyle: SupportOptionView.Style,
            titleStyle: StyledLabel.Style,
            descriptionStyle: StyledLabel.Style,
            lineStyle: LineView.Style,
            closeButtonStyle: PushButton.Style
        ) {
            self.optionsStyle = optionsStyle
            self.lineStyle = lineStyle
            self.titleStyle = titleStyle
            self.descriptionStyle = descriptionStyle
            self.closeButtonStyle = closeButtonStyle
        }
    }

    public struct Option: Identifiable {
        public let id: String
        public let title: String
        public let description: String

        public init(id: String, title: String, description: String) {
            self.id = id
            self.title = title
            self.description = description
        }
    }

    public enum State {
        case `default`
        case loading
    }
}

// MARK: - Class

public final class SupportContentView: View {
    private enum Constants {
        static let width: CGFloat = 452
        static let animatedImageAspectRatio: CGFloat = 9 / 16
        static let confettiTopOffset: CGFloat = 150
        static let contentHorizontalInset: CGFloat = 25
        static let contentTopInset: CGFloat = 35
        static let contentBottomInset: CGFloat = 20

        static let stateAnimationDuration: TimeInterval = 0.2
        static let visibleAlpha: CGFloat = 1
        static let hiddenAlpha: CGFloat = 0
    }

    private lazy var headerView = SupportContentHeaderView()
    private lazy var detailsView = SupportContentDetailsView()
    private lazy var confettiView = ConfettiView()

    private lazy var loadingIndicator: NSProgressIndicator = {
        let indicator = NSProgressIndicator()
        indicator.controlSize = .regular
        indicator.style = .spinning
        indicator.isIndeterminate = true
        return indicator
    }()

    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(headerView)
        addSubview(confettiView)
        addSubview(detailsView)
        addSubview(loadingIndicator)
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        detailsView.translatesAutoresizingMaskIntoConstraints = false
        confettiView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Constants.width),

            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerView.heightAnchor.constraint(
                equalTo: headerView.widthAnchor,
                multiplier: Constants.animatedImageAspectRatio
            ),

            confettiView.leadingAnchor.constraint(equalTo: leadingAnchor),
            confettiView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.confettiTopOffset),
            confettiView.trailingAnchor.constraint(equalTo: trailingAnchor),
            confettiView.bottomAnchor.constraint(equalTo: bottomAnchor),

            detailsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.contentHorizontalInset),
            detailsView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.contentTopInset),
            detailsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.contentHorizontalInset),
            detailsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.contentBottomInset),

            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            detailsView.style = style
        }
    }

    public weak var animatedImageDelegate: AnimatedImageViewDelegate? {
        didSet {
            headerView.animatedImageDelegate = animatedImageDelegate
        }
    }

    public func beginAnimation() {
        headerView.beginAnimation()
        detailsView.spawnHearts()
    }

    public var closeAction: Button.Action? {
        didSet {
            detailsView.closeAction = closeAction
        }
    }

    public var optionAction: OptionAction? {
        didSet {
            detailsView.optionAction = optionAction
        }
    }

    public var options: [Option] = [] {
        didSet {
            detailsView.options = options
        }
    }

    public var titleText: String? {
        didSet {
            detailsView.titleText = titleText
        }
    }

    public var descriptionFirstText: String? {
        didSet {
            detailsView.descriptionFirstText = descriptionFirstText
        }
    }

    public var descriptionSecondText: String? {
        didSet {
            detailsView.descriptionSecondText = descriptionSecondText
        }
    }

    public var descriptionThirdText: String? {
        didSet {
            detailsView.descriptionThirdText = descriptionThirdText
        }
    }

    public var closeButtonText: String? {
        didSet {
            detailsView.closeButtonText = closeButtonText
        }
    }

    public var avatarImage: NSImage? {
        didSet {
            detailsView.avatarImage = avatarImage
        }
    }

    public var particleImage: NSImage? {
        didSet {
            confettiView.particleImage = particleImage
        }
    }

    public var heartParticleImage: NSImage? {
        didSet {
            detailsView.heartParticleImage = heartParticleImage
        }
    }

    public func startConfetti() {
        confettiView.startConfetti()
    }

    public func setState(state: State, animated: Bool) {
        func setAlpha(views: [NSView: CGFloat], animated: Bool, completion: @escaping () -> Void) {
            if animated {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = Constants.stateAnimationDuration
                    views.forEach { $0.key.animator().alphaValue = $0.value }
                }, completionHandler: { [weak self] in
                    completion()
                    self?.loadingIndicator.startAnimation(self)
                })
            } else {
                views.forEach { $0.key.alphaValue = $0.value }
                completion()
            }
        }

        switch state {
        case .default:
            isUserInteractionsEnabled = true
            let views: [NSView: CGFloat] = [
                headerView: Constants.visibleAlpha,
                detailsView: Constants.visibleAlpha,
                confettiView: Constants.visibleAlpha,
                loadingIndicator: Constants.hiddenAlpha
            ]
            setAlpha(views: views, animated: animated) { [weak self] in
                self?.loadingIndicator.stopAnimation(self)
            }
        case .loading:
            isUserInteractionsEnabled = false
            let views: [NSView: CGFloat] = [
                detailsView: Constants.hiddenAlpha,
                confettiView: Constants.hiddenAlpha,
                loadingIndicator: Constants.visibleAlpha,
                headerView: Constants.hiddenAlpha
            ]
            setAlpha(views: views, animated: animated) { [weak self] in
                self?.loadingIndicator.startAnimation(self)
            }
        }
    }

    public func deselectAllOptions() {
        detailsView.deselectAllOptions()
    }
}
