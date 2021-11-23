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

extension TextView {
    public typealias ClickAction = (Any) -> Void
}

public class TextView: NSTextView {
    public override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    
    public override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        delegate = self
        textContainerInset = .zero
        textContainer?.lineFragmentPadding = 0
    }
    
    // MARK: - Public
    
    public var clickAction: ClickAction?
    
    public override var intrinsicContentSize: NSSize {
        guard let container = textContainer, let manager = container.layoutManager else {
            return super.intrinsicContentSize
        }
        manager.ensureLayout(for: container)
        return manager.usedRect(for: container).size
    }
    
    public func setAttributedString(_ string: NSAttributedString) {
        textStorage?.setAttributedString(string)
        invalidateIntrinsicContentSize()
    }
}

// MARK: - NSTextViewDelegate

extension TextView: NSTextViewDelegate {
    public func textDidChange(_ notification: Notification) {
        invalidateIntrinsicContentSize()
    }
    
    public override func clicked(onLink link: Any, at charIndex: Int) {
        clickAction?(link)
    }
}
