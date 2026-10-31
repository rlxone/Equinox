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

extension MainContentView {
    public struct Style {
        let bottomBarStyle: BottomBarView.Style
        let compressionScopeTitles: [String]

        public init(
            bottomBarStyle: BottomBarView.Style,
            compressionScopeTitles: [String]
        ) {
            self.bottomBarStyle = bottomBarStyle
            self.compressionScopeTitles = compressionScopeTitles
        }
    }
}

// MARK: - Class

public final class MainContentView: View {
    private lazy var visualEffectView = VisualEffectView(material: .windowBackground, blendingMode: .behindWindow)
    private lazy var bottomBarView = BottomBarView()
    private lazy var exportSettingsView = ExportSettingsView()
    
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
        bottomBarView.accessoryView = exportSettingsView
        addSubview(visualEffectView)
        visualEffectView.contentView.addSubview(containerView)
        visualEffectView.contentView.addSubview(bottomBarView)
    }

    private func setupConstraints() {
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomBarView.leadingAnchor.constraint(
                equalTo: visualEffectView.contentView.leadingAnchor
            ),
            bottomBarView.trailingAnchor.constraint(
                equalTo: visualEffectView.contentView.trailingAnchor
            ),
            bottomBarView.bottomAnchor.constraint(
                equalTo: visualEffectView.contentView.bottomAnchor
            ),
            bottomBarView.heightAnchor.constraint(
                equalToConstant: BottomBarView.preferredHeight
            )
        ])

        NSLayoutConstraint.activate([
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            containerView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor),
            containerView.bottomAnchor.constraint(
                equalTo: visualEffectView.contentView.bottomAnchor
            ),
            containerView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor)
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            bottomBarView.style = style?.bottomBarStyle
            if let style = style {
                exportSettingsView.setCompressionScopeTitles(
                    style.compressionScopeTitles
                )
            }
        }
    }

    public fileprivate(set) lazy var containerView = View()

    public var active: Bool {
        get {
            return visualEffectView.active
        }
        set {
            visualEffectView.active = newValue
        }
    }

    public var createButtonAction: Button.Action? {
        didSet {
            bottomBarView.buttonAction = createButtonAction
        }
    }

    public var createButtonTitle: String {
        get {
            return bottomBarView.buttonTitle
        }
        set {
            bottomBarView.buttonTitle = newValue
        }
    }

    public var isCreateButtonEnabled: Bool {
        get {
            return bottomBarView.isButtonEnabled
        }
        set {
            bottomBarView.isButtonEnabled = newValue
        }
    }

    public var infoText: String {
        get { bottomBarView.infoText }
        set { bottomBarView.infoText = newValue }
    }

    public var compressionScopeIndex: Int {
        return exportSettingsView.compressionScopeIndex
    }

    public var imageQuality: Int {
        return exportSettingsView.imageQuality
    }

    public var encodingSettingsDidChange: (() -> Void)? {
        get { exportSettingsView.settingsDidChange }
        set { exportSettingsView.settingsDidChange = newValue }
    }
}

private final class ExportSettingsView: NSView {
    private enum Constants {
        static let rowSpacing: CGFloat = 16
    }

    var settingsDidChange: (() -> Void)?
    private lazy var compressionScopeLabel = makeLabel(
        "Apply lossy compression to:"
    )
    private lazy var qualityLabel = makeLabel("Image quality:")
    private lazy var compressionScopePopUp = NSPopUpButton()
    private var compressionScopeWidthConstraint: NSLayoutConstraint?
    private var settingsWidthConstraint: NSLayoutConstraint?
    private var settingsRows: NSStackView?
    private lazy var compressionHelpButton: NSButton = {
        let button = NSButton(
            image: NSImage(
                systemSymbolName: "questionmark.circle",
                accessibilityDescription: "Compression options"
            )!,
            target: self,
            action: #selector(compressionHelpClicked(_:))
        )
        button.bezelStyle = .regularSquare
        button.isBordered = false
        button.controlSize = .regular
        button.setAccessibilityLabel("Explain compression options")
        return button
    }()
    private lazy var compressionHelpPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = makeCompressionHelpController()
        return popover
    }()
    private lazy var qualitySlider = NSSlider(
        value: 80,
        minValue: 1,
        maxValue: 99,
        target: self,
        action: #selector(qualitySliderChanged(_:))
    )
    private lazy var qualityValueButton: NSButton = {
        let button = NSButton(
            title: "80%",
            target: self,
            action: #selector(qualityValueClicked(_:))
        )
        button.bezelStyle = .rounded
        button.controlSize = .regular
        return button
    }()
    private lazy var popoverQualityValueLabel = makeLabel("80%")
    private lazy var qualityPopover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = makeQualityPopoverController()
        return popover
    }()

    var compressionScopeIndex: Int {
        return compressionScopePopUp.indexOfSelectedItem
    }

    var imageQuality: Int {
        return Int(qualitySlider.doubleValue)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        compressionScopePopUp.controlSize = .regular
        compressionScopePopUp.alignment = .left
        let menuTitleStyle = NSMutableParagraphStyle()
        menuTitleStyle.alignment = .left
        for item in compressionScopePopUp.itemArray {
            item.attributedTitle = NSAttributedString(
                string: item.title,
                attributes: [.paragraphStyle: menuTitleStyle]
            )
        }
        let compressionScopeWidth = max(
            compressionScopePopUp.frame.width,
            compressionScopePopUp.intrinsicContentSize.width
        )
        compressionHelpButton.widthAnchor.constraint(equalToConstant: 24)
            .isActive = true
        compressionHelpButton.heightAnchor.constraint(equalToConstant: 24)
            .isActive = true
        qualitySlider.controlSize = .small
        qualitySlider.isContinuous = true
        compressionScopePopUp.target = self
        compressionScopePopUp.action = #selector(compressionScopeChanged(_:))

        let compressionScopeControls = NSStackView(views: [
            compressionScopePopUp,
            compressionHelpButton
        ])
        compressionScopeControls.orientation = .horizontal
        compressionScopeControls.alignment = .centerY
        compressionScopeControls.spacing = 4

        let compressionRow = NSStackView(views: [
            compressionScopeLabel,
            compressionScopeControls
        ])
        compressionRow.orientation = .horizontal
        compressionRow.alignment = .centerY
        compressionRow.spacing = 8

        let qualityControls = NSStackView(views: [
            qualitySlider,
            qualityValueButton
        ])
        qualityControls.orientation = .horizontal
        qualityControls.alignment = .centerY
        qualityControls.spacing = 8

        let qualityRow = NSStackView(views: [qualityLabel, qualityControls])
        qualityRow.orientation = .horizontal
        qualityRow.alignment = .centerY
        qualityRow.spacing = 8

        let rows = NSStackView(views: [compressionRow, qualityRow])
        rows.orientation = .vertical
        rows.alignment = .leading
        rows.spacing = Constants.rowSpacing
        rows.translatesAutoresizingMaskIntoConstraints = false
        settingsRows = rows
        addSubview(rows)

        let widthConstraint = compressionScopePopUp.widthAnchor.constraint(
            equalToConstant: compressionScopeWidth
        )
        widthConstraint.isActive = true
        compressionScopeWidthConstraint = widthConstraint
        qualityValueButton.widthAnchor.constraint(equalToConstant: 60)
            .isActive = true
        let settingsWidth = widthAnchor.constraint(
            equalToConstant: requiredSettingsWidth(
                compressionScopeWidth: compressionScopeWidth
            )
        )
        settingsWidth.isActive = true
        settingsWidthConstraint = settingsWidth
        NSLayoutConstraint.activate([
            rows.leadingAnchor.constraint(equalTo: leadingAnchor),
            rows.trailingAnchor.constraint(equalTo: trailingAnchor),
            rows.topAnchor.constraint(equalTo: topAnchor),
            rows.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        compressionScopePopUp.setAccessibilityLabel(
            "Apply lossy compression to"
        )
        qualityValueButton.setAccessibilityLabel("Image quality")
    }

    func setCompressionScopeTitles(_ titles: [String]) {
        guard titles.count == 4 else { return }
        compressionScopeWidthConstraint?.isActive = false
        compressionScopePopUp.removeAllItems()
        compressionScopePopUp.addItems(withTitles: titles)
        let optionFont = NSFont.systemFont(ofSize: 13)
        let widestTitleWidth = titles.map {
            titleWidth($0, font: optionFont)
        }.max() ?? 0
        compressionScopeWidthConstraint?.constant = widestTitleWidth + 48
        compressionScopeWidthConstraint?.isActive = true
        settingsRows?.layoutSubtreeIfNeeded()
        compressionScopePopUp.selectItem(at: 2)
        settingsRows?.layoutSubtreeIfNeeded()
        settingsWidthConstraint?.constant = requiredSettingsWidth(
            compressionScopeWidth: widestTitleWidth + 48
        )
    }

    private func requiredSettingsWidth(
        compressionScopeWidth: CGFloat
    ) -> CGFloat {
        let popupWidth = max(
            compressionScopeWidth,
            compressionScopePopUp.intrinsicContentSize.width
        )
        let compressionRowWidth = compressionScopeLabel.fittingSize.width
            + 8 + popupWidth + 4 + 24
        let qualityRowWidth = qualityLabel.fittingSize.width
            + 8 + qualitySlider.fittingSize.width + 8
            + qualityValueButton.fittingSize.width
        return max(compressionRowWidth, qualityRowWidth)
    }

    @objc
    private func compressionHelpClicked(_ sender: NSButton) {
        if !compressionHelpPopover.isShown {
            compressionHelpPopover.show(
                relativeTo: sender.bounds,
                of: sender,
                preferredEdge: .maxY
            )
        }
    }

    @objc
    private func qualityValueClicked(_ sender: NSButton) {
        if !qualityPopover.isShown {
            qualityPopover.show(
                relativeTo: sender.bounds,
                of: sender,
                preferredEdge: .maxY
            )
        }
    }

    @objc
    private func qualitySliderChanged(_ sender: NSSlider) {
        let value = "\(Int(sender.doubleValue))%"
        qualityValueButton.title = value
        popoverQualityValueLabel.stringValue = value
        settingsDidChange?()
    }

    @objc
    private func compressionScopeChanged(_ sender: NSPopUpButton) {
        settingsDidChange?()
    }

    private func makeLabel(_ title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 13)
        label.textColor = .labelColor
        return label
    }

    private func titleWidth(_ title: String, font: NSFont) -> CGFloat {
        return (title as NSString).size(withAttributes: [.font: font]).width
    }

    private func makeQualityPopoverController() -> NSViewController {
        let controller = NSViewController()
        let row = NSStackView(views: [
            qualitySlider,
            popoverQualityValueLabel
        ])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false
        qualitySlider.widthAnchor.constraint(equalToConstant: 190)
            .isActive = true
        popoverQualityValueLabel.widthAnchor.constraint(equalToConstant: 36)
            .isActive = true
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 250, height: 54))
        view.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            row.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            row.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        controller.view = view
        return controller
    }

    private func makeCompressionHelpController() -> NSViewController {
        let controller = NSViewController()
        let contentWidth: CGFloat = 358
        let inset: CGFloat = 16
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.widthAnchor.constraint(equalToConstant: contentWidth)
            .isActive = true

        let title = NSTextField(labelWithString: "Compression options")
        title.font = .systemFont(ofSize: 15, weight: .semibold)
        title.textColor = .labelColor
        title.widthAnchor.constraint(equalToConstant: contentWidth)
            .isActive = true
        stack.addArrangedSubview(title)
        stack.setCustomSpacing(10, after: title)

        let explanations = [
            (
                "All images",
                "Recompresses every source image lossily. This can greatly " +
                    "reduce file size, but may reduce the quality of every " +
                    "image, including HEIC."
            ),
            (
                "All but HEIC",
                "Copies HEIC images unchanged and recompresses every other " +
                    "format lossily, including PNG. This can reduce file " +
                    "size, but may reduce the quality of non-HEIC images."
            ),
            (
                "Lossy formats but HEIC",
                "Copies HEIC images unchanged, converts lossless formats " +
                    "such as PNG losslessly, and recompresses lossy formats " +
                    "such as JPG. This reduces lossy source sizes while " +
                    "preserving quality for lossless and HEIC sources."
            ),
            (
                "No images",
                "Copies HEIC images unchanged and converts every other " +
                    "format losslessly. Image quality is preserved, but " +
                    "the resulting file can be much larger."
            )
        ]

        for (headingText, explanationText) in explanations {
            let heading = NSTextField(labelWithString: headingText)
            heading.font = .systemFont(ofSize: 13, weight: .semibold)
            heading.textColor = .labelColor
            heading.widthAnchor.constraint(equalToConstant: contentWidth)
                .isActive = true
            stack.addArrangedSubview(heading)

            let explanation = NSTextField(
                wrappingLabelWithString: explanationText
            )
            explanation.font = .systemFont(ofSize: 13)
            explanation.textColor = .labelColor
            explanation.maximumNumberOfLines = 0
            explanation.preferredMaxLayoutWidth = contentWidth
            explanation.widthAnchor.constraint(equalToConstant: contentWidth)
                .isActive = true
            stack.addArrangedSubview(explanation)
            stack.setCustomSpacing(9, after: explanation)
        }

        let contentHeight = ceil(stack.fittingSize.height)
        let view = NSView(frame: NSRect(
            x: 0,
            y: 0,
            width: contentWidth + inset * 2,
            height: contentHeight + inset * 2 - 9
        ))
        stack.frame = NSRect(
            x: inset,
            y: inset,
            width: contentWidth,
            height: contentHeight
        )
        view.addSubview(stack)
        controller.view = view
        return controller
    }
}
