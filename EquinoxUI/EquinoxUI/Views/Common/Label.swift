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

public class Label: NSTextField {
    private enum Constants {
        static let minimumScaleFactor: CGFloat = 0.5
        static let binarySearchSteps = 10
    }

    private var baseFont: NSFont?
    private var isApplyingFittedFont = false
    private var originalLineBreakMode: NSLineBreakMode?
    private var originalWraps: Bool?
    private var originalUsesSingleLineMode: Bool?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        isEditable = false
        drawsBackground = false
        isBordered = false
        baseFont = font
    }
    
    // MARK: Public

    public override var font: NSFont? {
        didSet {
            guard !isApplyingFittedFont else {
                return
            }

            baseFont = font
            updateFontToFitWidthIfNeeded()
        }
    }

    public override var stringValue: String {
        didSet {
            updateFontToFitWidthIfNeeded()
        }
    }

    public var adjustsFontSizeToFitWidth: Bool = false {
        didSet {
            updateLineBreakBehaviorForFontAdjustment()
            updateFontToFitWidthIfNeeded()
        }
    }

    public override func layout() {
        super.layout()
        updateFontToFitWidthIfNeeded()
    }
}

// MARK: - Adjust Font Size To Fit Width

extension Label {
    private func updateFontToFitWidthIfNeeded() {
        guard let baseFont else {
            return
        }

        guard adjustsFontSizeToFitWidth else {
            applyFont(baseFont)
            return
        }

        guard !stringValue.isEmpty else {
            applyFont(baseFont)
            return
        }

        let drawingRect = cell?.drawingRect(forBounds: bounds) ?? bounds
        let availableWidth = max(0, drawingRect.width)
        guard availableWidth > 0 else {
            return
        }

        let maxSize = baseFont.pointSize
        let minSize = max(1, maxSize * Constants.minimumScaleFactor)

        if textWidth(for: baseFont, height: drawingRect.height) <= availableWidth {
            applyFont(baseFont)
            return
        }

        var low = minSize
        var high = maxSize

        for _ in 0..<Constants.binarySearchSteps {
            let middle = (low + high) / 2
            let candidateFont = makeFont(from: baseFont, size: middle)

            if textWidth(for: candidateFont, height: drawingRect.height) <= availableWidth {
                low = middle
            } else {
                high = middle
            }
        }

        applyFont(makeFont(from: baseFont, size: floor(low)))
    }

    private func textWidth(for font: NSFont, height: CGFloat) -> CGFloat {
        let attributed = NSMutableAttributedString(attributedString: attributedStringValue)
        let fullRange = NSRange(location: 0, length: attributed.length)
        attributed.addAttribute(.font, value: font, range: fullRange)

        guard let cellCopy = cell?.copy() as? NSTextFieldCell else {
            return ceil(attributed.size().width)
        }

        cellCopy.attributedStringValue = attributed
        cellCopy.wraps = false
        cellCopy.usesSingleLineMode = true
        cellCopy.lineBreakMode = .byClipping

        let fittingBounds = NSRect(
            x: 0,
            y: 0,
            width: CGFloat.greatestFiniteMagnitude,
            height: max(1, height)
        )

        return ceil(cellCopy.cellSize(forBounds: fittingBounds).width)
    }

    private func applyFont(_ font: NSFont) {
        guard self.font != font else {
            return
        }

        isApplyingFittedFont = true
        self.font = font
        isApplyingFittedFont = false
    }

    private func makeFont(from font: NSFont, size: CGFloat) -> NSFont {
        if #available(macOS 10.15, *) {
            return font.withSize(size)
        }

        return NSFont(descriptor: font.fontDescriptor, size: size) ?? font
    }

    private func updateLineBreakBehaviorForFontAdjustment() {
        guard let cell else {
            return
        }

        if adjustsFontSizeToFitWidth {
            if originalLineBreakMode == nil {
                originalLineBreakMode = cell.lineBreakMode
                originalWraps = cell.wraps
                originalUsesSingleLineMode = cell.usesSingleLineMode
            }

            cell.wraps = false
            cell.usesSingleLineMode = true
            cell.lineBreakMode = .byClipping
        } else {
            if let originalWraps {
                cell.wraps = originalWraps
            }
            if let originalUsesSingleLineMode {
                cell.usesSingleLineMode = originalUsesSingleLineMode
            }
            if let originalLineBreakMode {
                cell.lineBreakMode = originalLineBreakMode
            }

            originalWraps = nil
            originalUsesSingleLineMode = nil
            originalLineBreakMode = nil
        }
    }
}
