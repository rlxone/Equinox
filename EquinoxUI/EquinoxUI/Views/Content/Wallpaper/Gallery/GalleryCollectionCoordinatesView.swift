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

extension GalleryCollectionCoordinatesView {
    public typealias FloatingChangeAction = (FloatingTextField) -> Void

    public struct Style {
        public struct OwnStyle {
            let stackBackgroundColor: NSColor
            let stackBorderColor: NSColor
            let flashColor: NSColor

            public init(stackBackgroundColor: NSColor, stackBorderColor: NSColor, flashColor: NSColor) {
                self.stackBackgroundColor = stackBackgroundColor
                self.stackBorderColor = stackBorderColor
                self.flashColor = flashColor
            }
        }

        let ownStyle: OwnStyle
        let separatorStyle: LineView.Style
        let altitudeStyle: StyledLabel.Style
        let azimuthStyle: StyledLabel.Style

        public init(
            ownStyle: OwnStyle,
            separatorStyle: LineView.Style,
            altitudeStyle: StyledLabel.Style,
            azimuthStyle: StyledLabel.Style
        ) {
            self.ownStyle = ownStyle
            self.altitudeStyle = altitudeStyle
            self.azimuthStyle = azimuthStyle
            self.separatorStyle = separatorStyle
        }
    }

    private enum Constants {
        static let cornerRadius: CGFloat = 4
        static let borderWidth: CGFloat = 1
        static let stackSpacing: CGFloat = 4
        static let separatorHeight: CGFloat = 1
        static let separatorOffset: CGFloat = 1
        static let edgeInsets: NSEdgeInsets = .init(top: 0, left: 11, bottom: 0, right: 8)
        static let flashAnimationDuration: TimeInterval = 0.35
    }
}

// MARK: - Class

public final class GalleryCollectionCoordinatesView: View {
    private lazy var altitudeLabel = StyledLabel()
    private lazy var azimuthLabel = StyledLabel()
    private lazy var separatorView = LineView()
    private lazy var altitudeContainer = View()
    private lazy var azimuthContainer = View()
    
    private lazy var altitudeTextField: FloatingTextField = {
        let textField = FloatingTextField()
        textField.floatingDelegate = self
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.focusRingType = .none
        return textField
    }()

    private lazy var azimuthTextField: FloatingTextField = {
        let textField = FloatingTextField()
        textField.floatingDelegate = self
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.focusRingType = .none
        return textField
    }()
    
    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }

    // MARK: - Life Cycle

    public override var wantsUpdateLayer: Bool {
        return true
    }

    public override func updateLayer() {
        super.updateLayer()
        stylize()
    }
    
    // MARK: - Setup
    
    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = Constants.cornerRadius
        layer?.borderWidth = Constants.borderWidth
        
        altitudeContainer.addSubview(altitudeLabel)
        altitudeContainer.addSubview(altitudeTextField)
        azimuthContainer.addSubview(azimuthLabel)
        azimuthContainer.addSubview(azimuthTextField)
        
        addSubview(altitudeContainer)
        addSubview(azimuthContainer)
        addSubview(separatorView)
        
        altitudeTextField.nextKeyView = azimuthTextField
        azimuthTextField.nextKeyView = altitudeTextField
    }

    private func setupConstraints() {
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        altitudeContainer.translatesAutoresizingMaskIntoConstraints = false
        azimuthContainer.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        altitudeLabel.translatesAutoresizingMaskIntoConstraints = false
        altitudeTextField.translatesAutoresizingMaskIntoConstraints = false
        azimuthLabel.translatesAutoresizingMaskIntoConstraints = false
        azimuthTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.separatorOffset),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.separatorOffset),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            separatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            altitudeContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            altitudeContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            altitudeContainer.topAnchor.constraint(equalTo: topAnchor),
            altitudeContainer.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            
            azimuthContainer.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            azimuthContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            azimuthContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            azimuthContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            altitudeLabel.leadingAnchor.constraint(equalTo: altitudeContainer.leadingAnchor, constant: Constants.edgeInsets.left),
            altitudeLabel.centerYAnchor.constraint(equalTo: altitudeContainer.centerYAnchor),
            
            altitudeTextField.leadingAnchor.constraint(equalTo: altitudeLabel.trailingAnchor, constant: Constants.stackSpacing),
            altitudeTextField.centerYAnchor.constraint(equalTo: altitudeContainer.centerYAnchor),
            altitudeTextField.trailingAnchor.constraint(equalTo: altitudeContainer.trailingAnchor, constant: -Constants.edgeInsets.right),
            
            azimuthLabel.leadingAnchor.constraint(equalTo: azimuthContainer.leadingAnchor, constant: Constants.edgeInsets.left),
            azimuthLabel.centerYAnchor.constraint(equalTo: azimuthContainer.centerYAnchor),
            
            azimuthTextField.leadingAnchor.constraint(equalTo: azimuthLabel.trailingAnchor, constant: Constants.stackSpacing),
            azimuthTextField.centerYAnchor.constraint(equalTo: azimuthContainer.centerYAnchor),
            azimuthTextField.trailingAnchor.constraint(equalTo: azimuthContainer.trailingAnchor, constant: -Constants.edgeInsets.right)
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
    
    public func flash() {
        guard let style = style, let currentBorderColor = layer?.borderColor else {
            return
        }
        
        let borderColorAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColorAnimation.duration = Constants.flashAnimationDuration
        borderColorAnimation.autoreverses = true
        borderColorAnimation.timingFunction = .init(name: .linear)
        borderColorAnimation.fromValue = currentBorderColor
        borderColorAnimation.toValue = style.ownStyle.flashColor.cgColor
        
        layer?.add(borderColorAnimation, forKey: nil)
    }
    
    public var azimuth: String? {
        didSet {
            azimuthTextField.stringValue = azimuth ?? String()
        }
    }
    
    public var altitude: String? {
        didSet {
            altitudeTextField.stringValue = altitude ?? String()
        }
    }
    
    public var altitudeText: String? {
        didSet {
            altitudeLabel.stringValue = altitudeText ?? String()
        }
    }

    public var altitudePlaceholder: String? {
        didSet {
            altitudeTextField.placeholderString = altitudePlaceholder
        }
    }

    public var azimuthText: String? {
        didSet {
            azimuthLabel.stringValue = azimuthText ?? String()
        }
    }

    public var azimuthPlaceholder: String? {
        didSet {
            azimuthTextField.placeholderString = azimuthPlaceholder
        }
    }

    public var onAzimuthChange: FloatingChangeAction?

    public var onAltitudeChange: FloatingChangeAction?
    
    // MARK: - Private
    
    private func stylize() {
        separatorView.style = style?.separatorStyle
        altitudeLabel.style = style?.altitudeStyle
        azimuthLabel.style = style?.azimuthStyle
        
        layer?.backgroundColor = style?.ownStyle.stackBackgroundColor.cgColor
        layer?.borderColor = style?.ownStyle.stackBorderColor.cgColor
        
        altitudeTextField.font = style?.altitudeStyle.font
        azimuthTextField.font = style?.azimuthStyle.font
    }
}

// MARK: - FloatingTextFieldDelegate

extension GalleryCollectionCoordinatesView: FloatingTextFieldDelegate {
    public func textDidChange(_ textField: FloatingTextField) {
        if textField == azimuthTextField {
            onAzimuthChange?(azimuthTextField)
        } else if textField == altitudeTextField {
            onAltitudeChange?(altitudeTextField)
        }
    }
    
    public func textDidTab(for view: NSView) {
    }
    
    public func textDidBackTab(for view: NSView) {
    }
}
