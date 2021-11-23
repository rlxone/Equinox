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

extension CreateBottomView {
    public struct Style {
        let tagStyle: TagItemView.Style
        let buttonsStyle: CreateButtonsView.Style
        let lineStyle: LineView.Style
        
        public init(tagStyle: TagItemView.Style, buttonsStyle: CreateButtonsView.Style, lineStyle: LineView.Style) {
            self.tagStyle = tagStyle
            self.buttonsStyle = buttonsStyle
            self.lineStyle = lineStyle
        }
    }
    
    private enum Constants {
        static let lineHeight: CGFloat = 1
        static let lineBottomOffset: CGFloat = 32
        static let tagBottomOffset: CGFloat = 25
        static let tagHeight: CGFloat = 32
        static let buttonsBottomOffset: CGFloat = 32
    }
}

// MARK: - Class

public final class CreateBottomView: View {
    private lazy var tagView = TagView()
    private lazy var lineView = LineView()
    private lazy var buttonsView = CreateButtonsView()
    
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
        addSubview(tagView)
        addSubview(lineView)
        addSubview(buttonsView)
    }
    
    private func setupConstraints() {
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        tagView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tagView.topAnchor.constraint(equalTo: topAnchor),
            tagView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tagView.heightAnchor.constraint(equalToConstant: Constants.tagHeight),
            
            lineView.topAnchor.constraint(equalTo: tagView.bottomAnchor, constant: Constants.tagBottomOffset),
            lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),
            
            buttonsView.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: Constants.lineBottomOffset),
            buttonsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.buttonsBottomOffset)
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
    
    public var saveButtonTitle: String? {
        didSet {
            buttonsView.saveButtonTitle = saveButtonTitle
        }
    }
    
    public var setButtonTitle: String? {
        didSet {
            buttonsView.setButtonTitle = setButtonTitle
        }
    }
    
    public var createButtonTitle: String? {
        didSet {
            buttonsView.createButtonTitle = createButtonTitle
        }
    }
    
    public var cancelButtonTitle: String? {
        didSet {
            buttonsView.cancelButtonTitle = cancelButtonTitle
        }
    }

    public var cancelButtonAction: Button.Action? {
        didSet {
            buttonsView.cancelButtonAction = cancelButtonAction
        }
    }

    public var saveButtonAction: Button.Action? {
        didSet {
            buttonsView.saveButtonAction = saveButtonAction
        }
    }

    public var setButtonAction: Button.Action? {
        didSet {
            buttonsView.setButtonAction = setButtonAction
        }
    }
    
    public var createButtonAction: Button.Action? {
        didSet {
            buttonsView.createButtonAction = createButtonAction
        }
    }
    
    public var shareButtonTitle: String? {
        didSet {
            buttonsView.shareButtonTitle = shareButtonTitle
        }
    }
    
    public var shareButtonAction: Button.Action? {
        didSet {
            buttonsView.shareButtonAction = shareButtonAction
        }
    }
    
    public var tags: [String] = [] {
        didSet {
            tagView.arrangedSubviews.forEach {
                tagView.removeArrangedSubview($0)
            }
            tags.forEach {
                tagView.add($0)
            }
        }
    }
    
    public func showButtons(success: Bool) {
        buttonsView.showButtons(success: success)
    }
    
    // MARK: - Private
    
    private func stylize() {
        tagView.style = style?.tagStyle
        buttonsView.style = style?.buttonsStyle
        lineView.style = style?.lineStyle
    }
}
