// Copyright (c) 2026 Dzmitry Miadziukha
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

public class GlassView: View {
    public let contentView: NSView
    private let effectView: NSView

    public init(style: GlassEffectStyle, fallbackVisualEffect: (material: NSVisualEffectView.Material, blendingMode: NSVisualEffectView.BlendingMode)) {
        if #available(macOS 26.0, *) {
            let view = GlassEffectView(style: style)
            contentView = view.contentView ?? NSView()
            view.contentView = contentView
            effectView = view
        } else {
            let view = VisualEffectView(material: fallbackVisualEffect.material, blendingMode: fallbackVisualEffect.blendingMode)
            contentView = view.contentView
            effectView = view
        }
        
        super.init()
        
        setup()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setup() {
        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            effectView.topAnchor.constraint(equalTo: topAnchor),
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public var cornerRadius: CGFloat {
        get {
            if #available(macOS 26.0, *), let glassEffectView = effectView as? GlassEffectView {
                return glassEffectView.cornerRadius
            } else {
                return effectView.layer?.cornerRadius ?? 0
            }
        }
        set {
            if #available(macOS 26.0, *), let glassEffectView = effectView as? GlassEffectView {
                glassEffectView.cornerRadius = newValue
            }
            layer?.cornerRadius = newValue
        }
    }
}
