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

extension BottomBarView {
    public typealias HelpAction = () -> Void
    
    public struct Style {
        let buttonStyle: PushButton.Style
        let lineStyle: LineView.Style

        public init(buttonStyle: PushButton.Style, lineStyle: LineView.Style) {
            self.buttonStyle = buttonStyle
            self.lineStyle = lineStyle
        }
    }
    
    private enum Constants {
        static let buttonWidth: CGFloat = 100
        static let buttonHeight: CGFloat = 32
        static let lineHeight: CGFloat = 1
    }
}

// MARK: - Class

public class BottomBarView: VisualEffectView {
    private lazy var button = PushButton()
    private lazy var lineView = LineView()
    
    private lazy var helpButton: NSButton = {
        let button = NSButton()
        button.bezelStyle = .helpButton
        button.title = String()
        button.target = self
        button.action = #selector(helpButtonAction)
        return button
    }()

    // MARK: - Initializer

    public init() {
        super.init(material: .windowBackground, blendingMode: .withinWindow)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(button)
        addSubview(lineView)
        addSubview(helpButton)
    }
    
    private func setupConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        helpButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Constants.buttonWidth),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),

            lineView.topAnchor.constraint(equalTo: topAnchor),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),
            
            helpButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            helpButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            button.style = style?.buttonStyle
            lineView.style = style?.lineStyle
        }
    }

    public var buttonAction: Button.Action? {
        didSet {
            button.onAction = buttonAction
        }
    }

    public var buttonTitle: String {
        get {
            return button.title
        }
        set {
            button.title = newValue
        }
    }

    public var isButtonEnabled: Bool {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }
    
    public var helpAction: HelpAction?
    
    // MARK: - Private
    
    @objc
    private func helpButtonAction(_ sender: NSButton) {
        helpAction?()
    }
}
