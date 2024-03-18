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
        let toolBarStyle: ToolBarView.Style
        let bottomBarStyle: BottomBarView.Style

        public init(
            toolBarStyle: ToolBarView.Style,
            bottomBarStyle: BottomBarView.Style
        ) {
            self.toolBarStyle = toolBarStyle
            self.bottomBarStyle = bottomBarStyle
        }
    }

    private enum Constants {
        static let toolBarHeight: CGFloat = 74
        static let bottomBarHeight: CGFloat = 74
        static let lineHeight: CGFloat = 1
    }
}

// MARK: - Class

public final class MainContentView: View {
    private lazy var visualEffectView = VisualEffectView(material: .windowBackground, blendingMode: .behindWindow)
    private lazy var toolBarView = ToolBarView()
    private lazy var lineView = LineView()
    private lazy var bottomBarView = BottomBarView()
    
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
        addSubview(visualEffectView)
        visualEffectView.contentView.addSubview(containerView)
        visualEffectView.contentView.addSubview(toolBarView)
        visualEffectView.contentView.addSubview(lineView)
        visualEffectView.contentView.addSubview(bottomBarView)
    }

    private func setupConstraints() {
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            toolBarView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            toolBarView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            toolBarView.topAnchor.constraint(equalTo: visualEffectView.contentView.topAnchor),
            toolBarView.heightAnchor.constraint(equalToConstant: Constants.toolBarHeight),

            lineView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: toolBarView.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),

            bottomBarView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: visualEffectView.contentView.bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: Constants.bottomBarHeight),

            containerView.topAnchor.constraint(equalTo: toolBarView.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: visualEffectView.contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: visualEffectView.contentView.trailingAnchor)
        ])
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            toolBarView.style = style?.toolBarStyle
            bottomBarView.style = style?.bottomBarStyle
        }
    }

    public fileprivate(set) lazy var containerView = View()

    public var active: Bool {
        get {
            return visualEffectView.active
        }
        set {
            visualEffectView.active = newValue
            toolBarView.active = newValue
        }
    }

    public var toolBarTitle: String {
        get {
            return toolBarView.largeTitleText
        }
        set {
            toolBarView.largeTitleText = newValue
        }
    }

    public var isToolBarBackButtonEnabled: Bool {
        get {
            return toolBarView.isBackButtonEnabled
        }
        set {
            toolBarView.isBackButtonEnabled = newValue
        }
    }

    public var toolBarBackButtonAction: Button.Action? {
        didSet {
            toolBarView.backButtonAction = toolBarBackButtonAction
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

    public var menuItems: [MenuView.Item] {
        get {
            return toolBarView.menuItems
        }
        set {
            toolBarView.menuItems = newValue
        }
    }
    
    public var helpAction: BottomBarView.HelpAction? {
        didSet {
            bottomBarView.helpAction = helpAction
        }
    }
}
