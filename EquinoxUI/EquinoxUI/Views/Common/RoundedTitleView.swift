// Copyright (c) 2024 Dmitry Meduho
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

extension RoundedTitleView {
    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor
            let borderColor: NSColor
            
            public init(backgroundColor: NSColor, borderColor: NSColor) {
                self.backgroundColor = backgroundColor
                self.borderColor = borderColor
            }
        }
        
        let ownStyle: OwnStyle
        let titleStyle: StyledLabel.Style
        
        public init(
            ownStyle: OwnStyle,
            titleStyle: StyledLabel.Style
        ) {
            self.ownStyle = ownStyle
            self.titleStyle = titleStyle
        }
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 4
    }
}

// MARK: - Class

public final class RoundedTitleView: View {
    private lazy var titleLabel = {
        let label = StyledLabel()
        label.alignment = .center
        return label
    }()
    
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
        wantsLayer = true
        layer?.borderWidth = Constants.borderWidth
        layer?.cornerRadius = Constants.cornerRadius
        
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.verticalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.verticalPadding)
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
    
    public var title: String? {
        didSet {
            titleLabel.stringValue = title ?? String()
        }
    }
    
    // MARK: - Private
    
    private func stylize() {
        guard let style = style else {
            return
        }
        
        layer?.backgroundColor = style.ownStyle.backgroundColor.cgColor
        layer?.borderColor = style.ownStyle.borderColor.cgColor
        titleLabel.style = style.titleStyle
    }
}
