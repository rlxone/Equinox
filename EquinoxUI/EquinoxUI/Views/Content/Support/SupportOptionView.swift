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

extension SupportOptionView {
    public typealias Action = () -> Void
    
    public struct Style {
        public struct OwnStyle {
            let backgroundColor: NSColor
            let borderColor: NSColor
            let highligtedBackgroundColor: NSColor
            let highligtedBorderColor: NSColor
            
            public init(
                backgroundColor: NSColor,
                borderColor: NSColor,
                highligtedBackgroundColor: NSColor,
                highligtedBorderColor: NSColor
            ) {
                self.backgroundColor = backgroundColor
                self.borderColor = borderColor
                self.highligtedBackgroundColor = highligtedBackgroundColor
                self.highligtedBorderColor = highligtedBorderColor
            }
        }
        
        let ownStyle: OwnStyle
        let titleStyle: StyledLabel.Style
        let descriptionStyle: StyledLabel.Style
        
        public init(
            ownStyle: OwnStyle,
            titleStyle: StyledLabel.Style,
            descriptionStyle: StyledLabel.Style
        ) {
            self.ownStyle = ownStyle
            self.titleStyle = titleStyle
            self.descriptionStyle = descriptionStyle
        }
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 16
        static let shadowOffset: CGSize = CGSize(width: 0, height: -10)
        static let shadowRadius: CGFloat = 10
        static let shadowOpacity: Float = 0.08
        static let shadowLayerIndex: UInt32 = 0
        static let borderWidth: CGFloat = 1
        static let stackSpacing: CGFloat = 0
        static let contentHorizontalInset: CGFloat = 8
        static let height: CGFloat = 64
    }
}

public class SupportOptionView: StackView {
    private lazy var backgroundView = View()
    private lazy var titleLabel: StyledLabel = {
        let titleLabel = StyledLabel()
        titleLabel.alignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        return titleLabel
    }()
    private lazy var descriptionLabel: StyledLabel = {
        let descriptionLabel = StyledLabel()
        descriptionLabel.alignment = .center
        descriptionLabel.adjustsFontSizeToFitWidth = true
        return descriptionLabel
    }()
    
    private lazy var shadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.anchorPoint = .zero
        layer.shadowOffset = Constants.shadowOffset
        layer.shadowRadius = Constants.shadowRadius
        layer.shadowOpacity = Constants.shadowOpacity
        return layer
    }()
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Life Cycle
    
    public override var wantsUpdateLayer: Bool {
        return true
    }

    public override func updateLayer() {
        super.updateLayer()
        stylize()
    }
    
    public override func layout() {
        super.layout()

        let path = NSBezierPath(roundedRect: bounds, xRadius: Constants.cornerRadius, yRadius: Constants.cornerRadius)
        shadowLayer.bounds = bounds
        shadowLayer.shadowPath = path.path
    }
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        isSelected = true
    }

    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        action?()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = Constants.cornerRadius
        layer?.masksToBounds = false
        layer?.insertSublayer(shadowLayer, at: Constants.shadowLayerIndex)
        
        backgroundView.wantsLayer = true
        backgroundView.layer?.masksToBounds = false
        backgroundView.layer?.borderWidth = Constants.borderWidth
        backgroundView.layer?.cornerRadius = Constants.cornerRadius
        
        spacing = Constants.stackSpacing
        orientation = .vertical
        distribution = .gravityAreas
        
        addSubview(backgroundView)
        addView(titleLabel, in: .center)
        addView(descriptionLabel, in: .center)
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.contentHorizontalInset),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.contentHorizontalInset),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.contentHorizontalInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.contentHorizontalInset),
            
            heightAnchor.constraint(equalToConstant: Constants.height)
        ])
    }
    
    // MARK: - Public
    
    var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }
    
    var titleText: String? {
        didSet {
            titleLabel.stringValue = titleText ?? String()
        }
    }
    
    var descriptionText: String? {
        didSet {
            descriptionLabel.stringValue = descriptionText ?? String()
        }
    }

    var action: Action?

    // MARK: - Private
    
    private func stylize() {
        if isSelected {
            backgroundView.layer?.borderColor = style?.ownStyle.highligtedBorderColor.cgColor
            backgroundView.layer?.backgroundColor = style?.ownStyle.highligtedBackgroundColor.cgColor
        } else {
            backgroundView.layer?.borderColor = style?.ownStyle.borderColor.cgColor
            backgroundView.layer?.backgroundColor = style?.ownStyle.backgroundColor.cgColor
        }
        titleLabel.style = style?.titleStyle
        descriptionLabel.style = style?.descriptionStyle
    }
}
