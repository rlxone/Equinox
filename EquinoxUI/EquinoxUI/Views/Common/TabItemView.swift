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

extension TabItemView {
    public typealias Action = (TabItemView) -> Void

    public struct Style {
        let font: NSFont
        let textColor: NSColor
        let highlightTextColor: NSColor
        let accentColor: NSColor
        let backgroundColor: NSColor

        public init(
            font: NSFont,
            textColor: NSColor,
            highlightTextColor: NSColor,
            accentColor: NSColor,
            backgroundColor: NSColor
        ) {
            self.font = font
            self.textColor = textColor
            self.highlightTextColor = highlightTextColor
            self.accentColor = accentColor
            self.backgroundColor = backgroundColor
        }
    }
    
    private enum Constants {
        static let titleHorizontalOffset: CGFloat = 20
    }
}

// MARK: - TabViewItem

public final class TabItemView: View {
    private var isSelected = false
    private lazy var titleLabel = StyledLabel()
    
    // MARK: - Initializer
    
    public override init() {
        super.init()
        setup()
    }
    
    // MARK: - Life Cycle
    
    public override func layout() {
        super.layout()
        layer?.cornerRadius = bounds.height / 2 - 1
    }

    public override var wantsUpdateLayer: Bool {
        return true
    }

    public override func updateLayer() {
        super.updateLayer()
        stylize()
    }

    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        isSelected = true
        action?(self)
        runWithEffectiveAppearance {
            stylize()
        }
    }
    
    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        wantsLayer = true
        titleLabel.alignment = .center
        addSubview(titleLabel)
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.titleHorizontalOffset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.titleHorizontalOffset),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
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

    public var action: Action?

    public var title: String {
        get {
            return titleLabel.stringValue
        }
        set {
            titleLabel.stringValue = newValue
        }
    }

    public var index: Int = 0

    public var selected: Bool {
        get {
            return isSelected
        }
        set {
            isSelected = newValue
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    // MARK: - Private

    private func stylize() {
        titleLabel.font = style?.font
        if isSelected {
            titleLabel.textColor = style?.highlightTextColor
            layer?.backgroundColor = style?.accentColor.cgColor
        } else {
            titleLabel.textColor = style?.textColor
            layer?.backgroundColor = style?.backgroundColor.cgColor
        }
    }
}
