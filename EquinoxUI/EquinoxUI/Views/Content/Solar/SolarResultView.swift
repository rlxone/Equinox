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

// MARK: - Protocols

public protocol SolarResultViewDelegate: AnyObject {
    func beginDraggingSession(in view: SolarResultView, with event: NSEvent)
}

// MARK: - Enums, Structs

extension SolarResultView {
    public struct Style {
        public struct OwnStyle {
            let contentBackgroundColor: NSColor
            let contentBackgroundBorderColor: NSColor
            let dragImage: NSImage

            public init(
                contentBackgroundColor: NSColor,
                contentBackgroundBorderColor: NSColor,
                dragImage: NSImage
            ) {
                self.contentBackgroundColor = contentBackgroundColor
                self.contentBackgroundBorderColor = contentBackgroundBorderColor
                self.dragImage = dragImage
            }
        }

        let ownStyle: OwnStyle
        let resultHeaderStyle: StyledLabel.Style
        let textFieldStyle: RoundedFloatingTextField.Style

        public init(
            ownStyle: OwnStyle,
            resultHeaderStyle: StyledLabel.Style,
            textFieldStyle: RoundedFloatingTextField.Style
        ) {
            self.ownStyle = ownStyle
            self.resultHeaderStyle = resultHeaderStyle
            self.textFieldStyle = textFieldStyle
        }
    }

    private enum Constants {
        static let borderWidth: CGFloat = 1
        static let contentCornerRadius: CGFloat = 8
        static let fieldCornerRadius: CGFloat = 4
        static let defaultEdgeInsets: NSEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 8)
        static let dragImageViewLeadingOffset: CGFloat = 20
        static let dragImageViewTopOffset: CGFloat = 17.5
        static let dragImageViewWidth: CGFloat = 17
        static let dragImageViewHeight: CGFloat = 17
        static let resultHeaderLabelLeadingOffset: CGFloat = 8
        static let resultHeaderLabelTopOffset: CGFloat = 16
        static let azimuthTextFieldLeadingOffset: CGFloat = 20
        static let azimuthTextFieldTopOffset: CGFloat = 10
        static let azimuthTextFieldHeight: CGFloat = 40
        static let azimuthTextFieldBottomOffset: CGFloat = 16
        static let altitudeTextFieldTopOffset: CGFloat = 10
        static let altitudeTextFieldLeadingOffset: CGFloat = 20
        static let altitudeTextFieldTrailingOffset: CGFloat = 20
        static let altitudeTextFieldHeight: CGFloat = 40
        static let tooltipPresentDelayMilliseconds = 100
    }
}

// MARK: - Class

public final class SolarResultView: View {
    private lazy var resultHeaderLabel = StyledLabel()
    private lazy var dragImageView: ImageView = {
        let imageView = ImageView()
        imageView.showTooltip = true
        imageView.tooltipPresentDelayMilliseconds = Constants.tooltipPresentDelayMilliseconds
        imageView.tooltipIdentifier = SolarMainContentView.TooltipIdentifier.dragAndDrop.rawValue
        return imageView
    }()

    private lazy var altitudeTextField: RoundedFloatingTextField = {
        let view = RoundedFloatingTextField()
        view.cornerRadius = Constants.fieldCornerRadius
        view.edgeInsets = Constants.defaultEdgeInsets
        view.isEditable = false
        view.isSelectable = true
        return view
    }()

    private lazy var azimuthTextField: RoundedFloatingTextField = {
        let view = RoundedFloatingTextField()
        view.cornerRadius = Constants.fieldCornerRadius
        view.edgeInsets = Constants.defaultEdgeInsets
        view.isEditable = false
        view.isSelectable = true
        return view
    }()
    
    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }
    
    // MARK: - Life Cycle

    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        delegate?.beginDraggingSession(in: self, with: event)
    }

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
        layer?.cornerRadius = Constants.contentCornerRadius
        layer?.borderWidth = Constants.borderWidth

        addSubview(resultHeaderLabel)
        addSubview(altitudeTextField)
        addSubview(azimuthTextField)
        addSubview(dragImageView)
    }

    private func setupConstraints() {
        resultHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        altitudeTextField.translatesAutoresizingMaskIntoConstraints = false
        azimuthTextField.translatesAutoresizingMaskIntoConstraints = false
        dragImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dragImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.dragImageViewLeadingOffset),
            dragImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.dragImageViewTopOffset),
            dragImageView.widthAnchor.constraint(equalToConstant: Constants.dragImageViewWidth),
            dragImageView.heightAnchor.constraint(equalToConstant: Constants.dragImageViewHeight),
            
            resultHeaderLabel.leadingAnchor.constraint(equalTo: dragImageView.trailingAnchor, constant: Constants.resultHeaderLabelLeadingOffset),
            resultHeaderLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.resultHeaderLabelTopOffset),
            
            azimuthTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.azimuthTextFieldLeadingOffset),
            azimuthTextField.topAnchor.constraint(equalTo: resultHeaderLabel.bottomAnchor, constant: Constants.azimuthTextFieldTopOffset),
            azimuthTextField.widthAnchor.constraint(equalTo: altitudeTextField.widthAnchor),
            azimuthTextField.heightAnchor.constraint(equalToConstant: Constants.azimuthTextFieldHeight),
            azimuthTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.azimuthTextFieldBottomOffset),

            altitudeTextField.topAnchor.constraint(equalTo: resultHeaderLabel.bottomAnchor, constant: Constants.altitudeTextFieldTopOffset),
            altitudeTextField.leadingAnchor.constraint(equalTo: azimuthTextField.trailingAnchor, constant: Constants.altitudeTextFieldLeadingOffset),
            altitudeTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.altitudeTextFieldTrailingOffset),
            altitudeTextField.heightAnchor.constraint(equalToConstant: Constants.altitudeTextFieldHeight)
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

    public weak var delegate: SolarResultViewDelegate?

    public var altitude: String? {
        didSet {
            altitudeTextField.text = altitude ?? String()
        }
    }

    public var azimuth: String? {
        didSet {
            azimuthTextField.text = azimuth ?? String()
        }
    }

    public var resultHeaderTitle: String? {
        didSet {
            resultHeaderLabel.stringValue = resultHeaderTitle ?? String()
        }
    }

    public var altitudeTitle: String? {
        didSet {
            altitudeTextField.title = altitudeTitle ?? String()
        }
    }

    public var azimuthTitle: String? {
        didSet {
            azimuthTextField.title = azimuthTitle ?? String()
        }
    }

    public var altitudePlaceholder: String? {
        didSet {
            altitudeTextField.placeholder = altitudePlaceholder
        }
    }

    public var azimuthPlaceholder: String? {
        didSet {
            azimuthTextField.placeholder = azimuthPlaceholder
        }
    }

    public var copyAction: RoundedFloatingTextField.CopyAction? {
        didSet {
            azimuthTextField.copyAction = copyAction
            altitudeTextField.copyAction = copyAction
        }
    }
    
    public override weak var tooltipDelegate: TooltipDelegate? {
        didSet {
            dragImageView.tooltipDelegate = tooltipDelegate
        }
    }

    public func snapshot() -> NSImage {
        guard let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds) else {
            return NSImage()
        }
        cacheDisplay(in: bounds, to: imageRepresentation)
        guard let cgImage = imageRepresentation.cgImage else {
            return NSImage()
        }
        return NSImage(cgImage: cgImage, size: bounds.size)
    }
    
    // MARK: - Private

    private func stylize() {
        resultHeaderLabel.style = style?.resultHeaderStyle
        altitudeTextField.style = style?.textFieldStyle
        azimuthTextField.style = style?.textFieldStyle
        dragImageView.image = style?.ownStyle.dragImage

        layer?.backgroundColor = style?.ownStyle.contentBackgroundColor.cgColor
        layer?.borderColor = style?.ownStyle.contentBackgroundBorderColor.cgColor
    }
}
