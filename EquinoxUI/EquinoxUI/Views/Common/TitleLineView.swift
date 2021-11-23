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

extension TitleLineView {
    public struct Style {
        let firstColor: NSColor
        let secondColor: NSColor

        public init(firstColor: NSColor, secondColor: NSColor) {
            self.firstColor = firstColor
            self.secondColor = secondColor
        }
    }
}

// MARK: - Class

public final class TitleLineView: View {
    public override func layout() {
        super.layout()
        needsDisplay = true
    }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let lineHeight = frame.height / 2

        let line1Path = NSBezierPath(
            rect: NSRect(
                origin: .zero,
                size: .init(width: frame.width, height: lineHeight)
            )
        )
        let line2Path = NSBezierPath(
            rect: NSRect(
                origin: .init(x: 0, y: lineHeight),
                size: .init(width: frame.width, height: lineHeight)
            )
        )

        style?.firstColor.setFill()
        line1Path.fill()
        style?.secondColor.setFill()
        line2Path.fill()
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            needsDisplay = true
        }
    }
}
