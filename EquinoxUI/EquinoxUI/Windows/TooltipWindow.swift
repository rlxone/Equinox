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

extension TooltipWindow {
    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor

            public init(backgroundColor: NSColor) {
                self.backgroundColor = backgroundColor
            }
        }

        let ownStyle: OwnStyle
        let tooltipStyle: TooltipView.Style

        public init(ownStyle: TooltipWindow.Style.OwnStyle, tooltipStyle: TooltipView.Style) {
            self.ownStyle = ownStyle
            self.tooltipStyle = tooltipStyle
        }
    }

    private enum Constants {
        static let defaultTooltipOffset: CGFloat = 8
        static let defaultWindowAnimationTime: TimeInterval = 0.25
    }
}

// MARK: - Class

public class TooltipWindow: NSWindow {
    public init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        setup()
    }

    // MARK: - Setup

    private func setup() {
        contentView = TooltipView()
        contentView?.alphaValue = 0

        ignoresMouseEvents = true
        isReleasedWhenClosed = false
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            stylize()
        }
    }

    public var tooltipView: TooltipView? {
        return contentView as? TooltipView
    }

    public var tooltipOffset: CGFloat = Constants.defaultTooltipOffset

    public func setWindowFrame(relativeTo point: NSPoint) {
        displayIfNeeded()
        let tooltipFrame = NSRect(
            x: point.x - frame.width / 2,
            y: point.y + tooltipOffset,
            width: frame.width,
            height: frame.height
        )
        setFrame(tooltipFrame, display: false)
    }

    public func present(animated: Bool) {
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = Constants.defaultWindowAnimationTime
                contentView?.animator().alphaValue = 1
            }
        } else {
            contentView?.animator().alphaValue = 1
        }
    }

    // MARK: - Private

    private func stylize() {
        backgroundColor = style?.ownStyle.backgroundColor
        tooltipView?.style = style?.tooltipStyle
    }
}
