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

extension ContainerButton {
    private enum Constants {
        static let interactionAnimationDuration: TimeInterval = 0.2
        static let highlightAlphaValue: CGFloat = 0.5
    }
}

// MARK: - Class

public final class ContainerButton: Button {
    public override init() {
        super.init()
        setup()
    }

    // MARK: - Life Cycle

    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        animateInteractions(isMouseDown: false)
    }

    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        animateInteractions(isMouseDown: true)
    }

    public override func hitTest(_ point: NSPoint) -> NSView? {
        return isInteractionsEnabled ? super.hitTest(point) : nil
    }

    // MARK: - Setup

    private func setup() {
        wantsLayer = true
        layer?.backgroundColor = .clear
        isBordered = false
        title = String()
    }

    // MARK: - Public

    public var isInteractionsEnabled = true

    // MARK: - Private

    private func animateInteractions(isMouseDown: Bool) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constants.interactionAnimationDuration
            context.timingFunction = .init(name: .easeOut)

            self.animator().alphaValue = isMouseDown ? Constants.highlightAlphaValue : 1
        }
    }
}
