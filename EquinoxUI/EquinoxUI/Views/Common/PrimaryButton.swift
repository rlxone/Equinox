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

extension PrimaryButton {
    public struct Style {
        let backgroundColor: NSColor
        let alternativeColor: NSColor
        let borderColor: NSColor

        public init(
            backgroundColor: NSColor,
            alternativeColor: NSColor,
            borderColor: NSColor
        ) {
            self.backgroundColor = backgroundColor
            self.alternativeColor = alternativeColor
            self.borderColor = borderColor
        }
    }
    
    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let cornerRadius: CGFloat = 12
    }
}

// MARK: - Class

public final class PrimaryButton: Button {
    public override init() {
        super.init()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        wantsLayer = true
        layer?.borderWidth = Constants.borderWidth
        layer?.cornerRadius = Constants.cornerRadius
    }

    // MARK: - Life Cycle

    public override var wantsUpdateLayer: Bool {
        return true
    }

    public override func updateLayer() {
        super.updateLayer()
        stylize()
    }

    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var isSelected: Bool {
        get {
            return state == .on
        }
        set {
            state = newValue ? .on : .off
        }
    }

    // MARK: - Private
    
    private func stylize() {
        if isSelected {
            if NSColor.currentControlTint == .graphiteControlTint {
                layer?.backgroundColor = style?.alternativeColor.cgColor
            } else {
                layer?.backgroundColor = NSColor.controlAccentColor.cgColor
            }
        } else {
            layer?.backgroundColor = style?.backgroundColor.cgColor
            layer?.borderColor = style?.borderColor.cgColor
        }
    }
}
