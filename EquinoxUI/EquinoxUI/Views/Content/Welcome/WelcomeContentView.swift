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

extension WelcomeContentView {
    public struct Style {
        public struct OwnStyle {
            let icon: NSImage
            
            public init(icon: NSImage) {
                self.icon = icon
            }
        }
        
        let ownStyle: OwnStyle
        let typeStyle: TypeView.Style
        let welcomeStyle: StyledLabel.Style
        let versionStyle: StyledLabel.Style
        let githubStyle: StyledLabel.Style
        
        public init(
            ownStyle: WelcomeContentView.Style.OwnStyle,
            typeStyle: TypeView.Style,
            welcomeStyle: StyledLabel.Style,
            versionStyle: StyledLabel.Style,
            githubStyle: StyledLabel.Style
        ) {
            self.ownStyle = ownStyle
            self.typeStyle = typeStyle
            self.welcomeStyle = welcomeStyle
            self.versionStyle = versionStyle
            self.githubStyle = githubStyle
        }
    }
    
    private enum Constants {
        static let welcomeVisualEffectViewWidth: CGFloat = 444
        static let iconImageViewTopOffset: CGFloat = 64
        static let iconImageViewWidth: CGFloat = 164
        static let iconImageViewHeight: CGFloat = 164
        static let welcomeLabelTopOffset: CGFloat = 16
        static let versionLabelTopOffset: CGFloat = 2
        static let githubButtonTopOffset: CGFloat = 16
        static let githubLabelContainerOffset: CGFloat = 8
    }
}

// MARK: - Class

public final class WelcomeContentView: View {
    private lazy var welcomeVisualEffectView = VisualEffectView(material: .windowBackground, blendingMode: .behindWindow)
    private lazy var sidebarVisualEffectView = VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
    
    private lazy var iconImageView = ImageView()
    private lazy var welcomeLabel = StyledLabel()
    private lazy var versionLabel = StyledLabel()
    private lazy var typeView = TypeView()
    
    private lazy var githubLabel = StyledLabel()
    private lazy var githubButton = ContainerButton()
    
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
        addSubview(welcomeVisualEffectView)
        welcomeVisualEffectView.contentView.addSubview(iconImageView)
        welcomeVisualEffectView.contentView.addSubview(welcomeLabel)
        welcomeVisualEffectView.contentView.addSubview(versionLabel)
        welcomeVisualEffectView.contentView.addSubview(githubButton)
        githubButton.addSubview(githubLabel)
        
        addSubview(sidebarVisualEffectView)
        sidebarVisualEffectView.contentView.addSubview(typeView)
    }
    
    private func setupConstraints() {
        setupContainerConstraints()
        setupWelcomeConstraints()
        setupTypeConstraints()
    }
    
    private func setupContainerConstraints() {
        welcomeVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        sidebarVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            welcomeVisualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            welcomeVisualEffectView.topAnchor.constraint(equalTo: topAnchor),
            welcomeVisualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            welcomeVisualEffectView.widthAnchor.constraint(equalToConstant: Constants.welcomeVisualEffectViewWidth),
            
            sidebarVisualEffectView.leadingAnchor.constraint(equalTo: welcomeVisualEffectView.trailingAnchor),
            sidebarVisualEffectView.topAnchor.constraint(equalTo: topAnchor),
            sidebarVisualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sidebarVisualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupWelcomeConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        githubButton.translatesAutoresizingMaskIntoConstraints = false
        githubLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: welcomeVisualEffectView.contentView.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: welcomeVisualEffectView.contentView.topAnchor, constant: Constants.iconImageViewTopOffset),
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconImageViewWidth),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconImageViewHeight),
            
            welcomeLabel.centerXAnchor.constraint(equalTo: welcomeVisualEffectView.contentView.centerXAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: Constants.welcomeLabelTopOffset),
            
            versionLabel.centerXAnchor.constraint(equalTo: welcomeVisualEffectView.contentView.centerXAnchor),
            versionLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: Constants.versionLabelTopOffset),
            
            githubButton.centerXAnchor.constraint(equalTo: welcomeVisualEffectView.contentView.centerXAnchor),
            githubButton.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: Constants.githubButtonTopOffset),
            
            githubLabel.leadingAnchor.constraint(equalTo: githubButton.leadingAnchor, constant: Constants.githubLabelContainerOffset),
            githubLabel.trailingAnchor.constraint(equalTo: githubButton.trailingAnchor, constant: -Constants.githubLabelContainerOffset),
            githubLabel.topAnchor.constraint(equalTo: githubButton.topAnchor, constant: Constants.githubLabelContainerOffset),
            githubLabel.bottomAnchor.constraint(equalTo: githubButton.bottomAnchor, constant: -Constants.githubLabelContainerOffset)
        ])
    }
    
    private func setupTypeConstraints() {
        typeView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            typeView.leadingAnchor.constraint(equalTo: sidebarVisualEffectView.contentView.leadingAnchor),
            typeView.trailingAnchor.constraint(equalTo: sidebarVisualEffectView.contentView.trailingAnchor),
            typeView.topAnchor.constraint(equalTo: sidebarVisualEffectView.contentView.topAnchor),
            typeView.bottomAnchor.constraint(equalTo: sidebarVisualEffectView.contentView.bottomAnchor)
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
    
    public var types: [TypeItemView.Item] = [] {
        didSet {
            typeView.items = types
        }
    }
    
    public var selectedTypeIndex: Int? {
        didSet {
            typeView.selectedIndex = selectedTypeIndex
        }
    }
    
    public var welcomeText: String? {
        didSet {
            welcomeLabel.stringValue = welcomeText ?? String()
        }
    }
    
    public var versionText: String? {
        didSet {
            versionLabel.stringValue = versionText ?? String()
        }
    }
    
    public var githubText: String? {
        didSet {
            githubLabel.stringValue = githubText ?? String()
        }
    }
    
    public var typeHeaderText: String? {
        didSet {
            typeView.headerText = typeHeaderText ?? String()
        }
    }
    
    public var typeDescriptionText: String? {
        didSet {
            typeView.descriptionText = typeDescriptionText ?? String()
        }
    }
    
    public var githubAction: Button.Action? {
        didSet {
            githubButton.onAction = githubAction
        }
    }
    
    public var typeAction: TypeView.Action? {
        didSet {
            typeView.action = typeAction
        }
    }
    
    // MARK: - Private
    
    private func stylize() {
        iconImageView.image = style?.ownStyle.icon
        typeView.style = style?.typeStyle
        welcomeLabel.style = style?.welcomeStyle
        versionLabel.style = style?.versionStyle
        githubLabel.style = style?.githubStyle
    }
}
