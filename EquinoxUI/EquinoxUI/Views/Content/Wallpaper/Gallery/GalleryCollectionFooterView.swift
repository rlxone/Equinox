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

extension GalleryCollectionFooterView {
    public typealias Action = () -> Void
    
    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor

            public init(backgroundColor: NSColor) {
                self.backgroundColor = backgroundColor
            }
        }
        
        let ownStyle: OwnStyle
        let infoStyle: StyledLabel.Style

        public init(ownStyle: OwnStyle, infoStyle: StyledLabel.Style) {
            self.ownStyle = ownStyle
            self.infoStyle = infoStyle
        }
    }
    
    private enum Constants {
        static let infoHorizontalOffset: CGFloat = 12
        static let infoVerticalOffset: CGFloat = 8
        static let animationDuration: TimeInterval = 0.3
    }
}

// MARK: - Class

public final class GalleryCollectionFooterView: VisualEffectView {
    private lazy var infoLabel = StyledLabel()

    private lazy var backgroundView: View = {
        let view = View()
        view.wantsLayer = true
        return view
    }()
    
    // MARK: - Initializer
    
    public init() {
        super.init(material: .toolTip, blendingMode: .withinWindow)
        setup()
    }

    // MARK: - Life Cycle

    public override func layout() {
        super.layout()
        let cornerRadius = bounds.height / 2
        layer?.cornerRadius = cornerRadius
        backgroundView.layer?.cornerRadius = cornerRadius
    }
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if !isHidden {
            action?()
        }
    }

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
        
        contentView.addSubview(backgroundView)
        backgroundView.addSubview(infoLabel)
    }

    private func setupConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            infoLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.infoHorizontalOffset
            ),
            infoLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.infoHorizontalOffset
            ),
            infoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.infoVerticalOffset),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.infoVerticalOffset)
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

    public var info: String? {
        didSet {
            infoLabel.stringValue = info ?? String()
        }
    }
    
    public var action: Action?

    public func animate(isHidden: Bool) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = Constants.animationDuration
            
            self.animator().alphaValue = isHidden ? 0 : 1
        }, completionHandler: {
            self.isHidden = isHidden
        })
    }
    
    // MARK: - Private

    private func stylize() {
        backgroundView.layer?.backgroundColor = style?.ownStyle.backgroundColor.cgColor
        infoLabel.style = style?.infoStyle
    }
}
