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

final class SupportContentDetailsView: View {
    private enum Constants {
        static let contentStackSpacing: CGFloat = 16

        static let textStackSpacing: CGFloat = 22
        static let descriptionTextStackSpacing: CGFloat = 10
        static let descriptionLabelAlpha: CGFloat = 0.75
        static let optionsStackSpacing: CGFloat = 10

        static let heartTopOffset: CGFloat = 32
        static let avatarSideSize: CGFloat = 150
        static let textStackWidth: CGFloat = 312
        static let descriptionWidth: CGFloat = 288
        static let lineHeight: CGFloat = 1
        static let optionsHeight: CGFloat = 64
        static let closeButtonWidth: CGFloat = 120
        static let closeButtonHeight: CGFloat = 32
    }

    private lazy var contentStackView: StackView = {
        let stackView = StackView()
        stackView.orientation = .vertical
        stackView.alignment = .centerX
        stackView.spacing = Constants.contentStackSpacing
        return stackView
    }()

    private lazy var heartView = HeartView()
    private lazy var avatarView = SupportAvatarView()

    private lazy var textStackView: StackView = {
        let stackView = StackView()
        stackView.orientation = .vertical
        stackView.alignment = .centerX
        stackView.spacing = Constants.textStackSpacing
        return stackView
    }()

    private lazy var descriptionTextStackView: StackView = {
        let stackView = StackView()
        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.spacing = Constants.descriptionTextStackSpacing
        return stackView
    }()

    private lazy var titleLabel: StyledLabel = {
        let label = StyledLabel()
        label.alignment = .center
        return label
    }()

    private lazy var descriptionFirstLabel: StyledLabel = {
        let label = StyledLabel()
        label.alignment = .center
        label.alphaValue = Constants.descriptionLabelAlpha
        return label
    }()

    private lazy var descriptionSecondLabel: StyledLabel = {
        let label = StyledLabel()
        label.alignment = .center
        label.alphaValue = Constants.descriptionLabelAlpha
        return label
    }()

    private lazy var descriptionThirdLabel: StyledLabel = {
        let label = StyledLabel()
        label.alignment = .center
        label.alphaValue = Constants.descriptionLabelAlpha
        return label
    }()

    private lazy var descriptionFirstLineView = LineView()
    private lazy var descriptionSecondLineView = LineView()
    private lazy var descriptionBottomLineView = LineView()

    private lazy var optionsStackView: StackView = {
        let stackView = StackView()
        stackView.spacing = Constants.optionsStackSpacing
        stackView.distribution = .fillEqually
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        return stackView
    }()

    private lazy var bottomLineView = LineView()
    private lazy var closeButton = PushButton()

    // MARK: - Initializer

    override init() {
        super.init()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupMainConstraints()
        setupDescriptionConstraints()
    }

    private func setupView() {
        addSubview(heartView)
        addSubview(contentStackView)

        contentStackView.addArrangedSubview(avatarView)
        contentStackView.addArrangedSubview(textStackView)
        contentStackView.addArrangedSubview(descriptionBottomLineView)
        contentStackView.addArrangedSubview(optionsStackView)
        contentStackView.addArrangedSubview(bottomLineView)
        contentStackView.addArrangedSubview(closeButton)

        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionTextStackView)

        descriptionTextStackView.addArrangedSubview(descriptionFirstLabel)
        descriptionTextStackView.addArrangedSubview(descriptionFirstLineView)
        descriptionTextStackView.addArrangedSubview(descriptionSecondLabel)
        descriptionTextStackView.addArrangedSubview(descriptionSecondLineView)
        descriptionTextStackView.addArrangedSubview(descriptionThirdLabel)

        avatarView.action = { [weak self] in
            self?.heartView.spawnHearts()
        }
    }

    private func setupMainConstraints() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        heartView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStackView.topAnchor.constraint(equalTo: topAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            heartView.leadingAnchor.constraint(equalTo: avatarView.leadingAnchor),
            heartView.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: Constants.heartTopOffset),
            heartView.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor),
            heartView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor),

            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSideSize),
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSideSize),

            optionsStackView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            optionsStackView.heightAnchor.constraint(equalToConstant: Constants.optionsHeight),

            bottomLineView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            bottomLineView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            bottomLineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),

            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonWidth),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonHeight)
        ])
    }

    private func setupDescriptionConstraints() {
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionFirstLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionSecondLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionThirdLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionFirstLineView.translatesAutoresizingMaskIntoConstraints = false
        descriptionSecondLineView.translatesAutoresizingMaskIntoConstraints = false
        descriptionBottomLineView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textStackView.widthAnchor.constraint(equalToConstant: Constants.textStackWidth),

            descriptionFirstLabel.widthAnchor.constraint(equalToConstant: Constants.descriptionWidth),
            descriptionSecondLabel.widthAnchor.constraint(equalToConstant: Constants.descriptionWidth),
            descriptionThirdLabel.widthAnchor.constraint(equalToConstant: Constants.descriptionWidth),

            descriptionFirstLineView.widthAnchor.constraint(equalToConstant: Constants.descriptionWidth),
            descriptionFirstLineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),

            descriptionSecondLineView.widthAnchor.constraint(equalToConstant: Constants.descriptionWidth),
            descriptionSecondLineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),

            descriptionBottomLineView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            descriptionBottomLineView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            descriptionBottomLineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight)
        ])
    }

    // MARK: - Public

    var style: SupportContentView.Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    var closeAction: Button.Action? {
        didSet {
            closeButton.onAction = closeAction
        }
    }

    var optionAction: SupportContentView.OptionAction?

    var options: [SupportContentView.Option] = [] {
        didSet {
            renderOptions()
        }
    }

    var titleText: String? {
        didSet {
            titleLabel.stringValue = titleText ?? String()
        }
    }

    var descriptionFirstText: String? {
        didSet {
            descriptionFirstLabel.stringValue = descriptionFirstText ?? String()
        }
    }

    var descriptionSecondText: String? {
        didSet {
            descriptionSecondLabel.stringValue = descriptionSecondText ?? String()
        }
    }

    var descriptionThirdText: String? {
        didSet {
            descriptionThirdLabel.stringValue = descriptionThirdText ?? String()
        }
    }

    var closeButtonText: String? {
        didSet {
            closeButton.title = closeButtonText ?? String()
        }
    }

    var avatarImage: NSImage? {
        didSet {
            avatarView.image = avatarImage
        }
    }

    var heartParticleImage: NSImage? {
        didSet {
            heartView.particleImage = heartParticleImage
        }
    }

    func deselectAllOptions() {
        optionsStackView.arrangedSubviews
            .compactMap { $0 as? SupportOptionView }
            .forEach { $0.isSelected = false }
    }
    
    func spawnHearts() {
        heartView.spawnHearts()
    }

    // MARK: - Private

    private func renderOptions() {
        optionsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        options.forEach { option in
            let view = SupportOptionView()
            view.style = style?.optionsStyle
            view.titleText = option.title
            view.descriptionText = option.description
            view.action = { [weak self] in
                self?.optionAction?(option)
            }
            optionsStackView.addArrangedSubview(view)
        }
        optionsStackView.isHidden = options.isEmpty
        descriptionBottomLineView.isHidden = options.isEmpty
    }

    private func stylize() {
        titleLabel.style = style?.titleStyle
        descriptionFirstLabel.style = style?.descriptionStyle
        descriptionSecondLabel.style = style?.descriptionStyle
        descriptionThirdLabel.style = style?.descriptionStyle
        descriptionFirstLineView.style = style?.lineStyle
        descriptionSecondLineView.style = style?.lineStyle
        bottomLineView.style = style?.lineStyle
        descriptionBottomLineView.style = style?.lineStyle
        closeButton.style = style?.closeButtonStyle

        optionsStackView.arrangedSubviews
            .compactMap { $0 as? SupportOptionView }
            .forEach { $0.style = style?.optionsStyle }
    }
}
