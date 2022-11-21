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

extension CreateButtonsView {
    public struct Style {
        public struct OwnStyle {
            let saveImage: NSImage
            let setImage: NSImage
            let fileImage: NSImage
            let cancelImage: NSImage
            let shareImage: NSImage

            public init(
                saveImage: NSImage,
                setImage: NSImage,
                fileImage: NSImage,
                cancelImage: NSImage,
                shareImage: NSImage
            ) {
                self.saveImage = saveImage
                self.setImage = setImage
                self.fileImage = fileImage
                self.cancelImage = cancelImage
                self.shareImage = shareImage
            }
        }

        let ownStyle: OwnStyle
        let pushStyle: RoundedPushButton.Style

        public init(ownStyle: OwnStyle, pushStyle: RoundedPushButton.Style) {
            self.ownStyle = ownStyle
            self.pushStyle = pushStyle
        }
    }

    private enum Constants {
        static let spacing: CGFloat = 25
        static let buttonWidth: CGFloat = 48
        static let buttonHeight: CGFloat = 72
    }
}

// MARK: - Class

public final class CreateButtonsView: StackView {
    private lazy var saveButton = RoundedPushButton()
    private lazy var createButton = RoundedPushButton()
    private lazy var shareButton = RoundedPushButton()
    private lazy var setButton = RoundedPushButton()
    private lazy var cancelButton = RoundedPushButton()

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
        spacing = Constants.spacing

        addArrangedSubview(saveButton)
        addArrangedSubview(setButton)
        addArrangedSubview(shareButton)
        addArrangedSubview(createButton)
        addArrangedSubview(cancelButton)

        arrangedSubviews.forEach {
            $0.isHidden = true
        }
    }

    private func setupConstraints() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        setButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            saveButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            createButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            createButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            shareButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            shareButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            setButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            setButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            cancelButton.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            cancelButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
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

    public func showButtons(success: Bool) {
        if success {
            saveButton.isHidden = false
            setButton.isHidden = false
            shareButton.isHidden = false
        }
        createButton.isHidden = false
        cancelButton.isHidden = false
    }

    public var saveButtonTitle: String? {
        didSet {
            saveButton.title = saveButtonTitle ?? String()
        }
    }

    public var setButtonTitle: String? {
        didSet {
            setButton.title = setButtonTitle ?? String()
        }
    }

    public var createButtonTitle: String? {
        didSet {
            createButton.title = createButtonTitle ?? String()
        }
    }

    public var cancelButtonTitle: String? {
        didSet {
            cancelButton.title = cancelButtonTitle ?? String()
        }
    }

    public var shareButtonTitle: String? {
        didSet {
            shareButton.title = shareButtonTitle ?? String()
        }
    }

    public var cancelButtonAction: Button.Action? {
        didSet {
            cancelButton.onAction = cancelButtonAction
        }
    }

    public var saveButtonAction: Button.Action? {
        didSet {
            saveButton.onAction = saveButtonAction
        }
    }

    public var setButtonAction: Button.Action? {
        didSet {
            setButton.onAction = setButtonAction
        }
    }

    public var createButtonAction: Button.Action? {
        didSet {
            createButton.onAction = createButtonAction
        }
    }

    public var shareButtonAction: Button.Action? {
        didSet {
            shareButton.onAction = shareButtonAction
        }
    }

    // MARK: - Private

    private func stylize() {
        saveButton.image = style?.ownStyle.saveImage
        setButton.image = style?.ownStyle.setImage
        createButton.image = style?.ownStyle.fileImage
        cancelButton.image = style?.ownStyle.cancelImage
        shareButton.image = style?.ownStyle.shareImage

        saveButton.style = style?.pushStyle
        createButton.style = style?.pushStyle
        setButton.style = style?.pushStyle
        cancelButton.style = style?.pushStyle
        shareButton.style = style?.pushStyle
    }
}
