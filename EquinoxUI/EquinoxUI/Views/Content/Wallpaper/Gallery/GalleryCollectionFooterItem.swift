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

extension GalleryCollectionFooterItem {
    public struct Style {
        let footerStyle: GalleryCollectionFooterView.Style

        public init(footerStyle: GalleryCollectionFooterView.Style) {
            self.footerStyle = footerStyle
        }
    }
}

// MARK: - Class

public final class GalleryCollectionFooterItem: NSView {
    private lazy var footerView = GalleryCollectionFooterView()
    private var isUserInteractionsEnabled = true
    
    // MARK: - Initializer

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    public override func hitTest(_ point: NSPoint) -> NSView? {
        return isUserInteractionsEnabled ? super.hitTest(point) : nil
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(footerView)
    }

    private func setupConstraints() {
        footerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            footerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            footerView.centerYAnchor.constraint(equalTo: centerYAnchor)
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
            footerView.info = info
        }
    }
    
    public var action: GalleryCollectionFooterView.Action? {
        didSet {
            footerView.action = action
        }
    }

    public func animate(isHidden: Bool) {
        isUserInteractionsEnabled = !isHidden
        footerView.animate(isHidden: isHidden)
    }
    
    // MARK: - Private

    private func stylize() {
        footerView.style = style?.footerStyle
    }
}
