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

extension SolarLocationView {
    public typealias ButtonAction = (Button) -> Void
    public typealias LongitudeChangeAction = (String) -> Void
    public typealias LatitudeChangeAction = (String) -> Void
    public typealias DateChangeAction = (Date) -> Void

    public struct Style {
        public struct OwnStyle {
            let contentBackgroundColor: NSColor
            let contentBackgroundBorderColor: NSColor
            let locationImage: NSImage

            public init(
                contentBackgroundColor: NSColor,
                contentBackgroundBorderColor: NSColor,
                locationImage: NSImage
            ) {
                self.contentBackgroundColor = contentBackgroundColor
                self.contentBackgroundBorderColor = contentBackgroundBorderColor
                self.locationImage = locationImage
            }
        }

        let ownStyle: OwnStyle
        let locationHeaderStyle: StyledLabel.Style
        let dateHeaderStyle: StyledLabel.Style
        let textFieldStyle: RoundedFloatingTextField.Style
        let datePickerStyle: RoundedDatePicker.Style
        let pushButtonStyle: PushButton.Style

        public init(
            ownStyle: OwnStyle,
            locationHeaderStyle: StyledLabel.Style,
            dateHeaderStyle: StyledLabel.Style,
            textFieldStyle: RoundedFloatingTextField.Style,
            datePickerStyle: RoundedDatePicker.Style,
            pushButtonStyle: PushButton.Style
        ) {
            self.ownStyle = ownStyle
            self.locationHeaderStyle = locationHeaderStyle
            self.dateHeaderStyle = dateHeaderStyle
            self.textFieldStyle = textFieldStyle
            self.datePickerStyle = datePickerStyle
            self.pushButtonStyle = pushButtonStyle
        }
    }

    private enum Constants {
        static var contentCornerRadius: CGFloat {
            if #available(macOS 26, *) {
                return 16
            }
            return 8
        }
        static let contentBorderWidth: CGFloat = 1
        static var fieldCornerRadius: CGFloat {
            if #available(macOS 26, *) {
                return 10
            }
            return 4
        }
        static let defaultEdgeInsets: NSEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: 8)
        static let locationHeaderLabelLeadingOffset: CGFloat = 20
        static let locationHeaderLabelTopOffset: CGFloat = 16
        static let dateHeaderLabelLeadingOffset: CGFloat = 20
        static let dateHeaderLabelTopOffset: CGFloat = 16
        static let locationButtonTopOffset: CGFloat = 16
        static let locationButtonWidth: CGFloat = 23
        static let locationButtonHeight: CGFloat = 23
        static let latitudeTextFieldTopOffset: CGFloat = 10
        static let latitudeTextFieldBottomOffset: CGFloat = 16
        static let latitudeTextFieldLeadingOffset: CGFloat = 20
        static let latitudeTextFieldWidthMultiplier: CGFloat = 0.32
        static let latitudeTextFieldHeight: CGFloat = 40
        static let longitudeTextFieldTopOffset: CGFloat = 10
        static let longitudeTextFieldLeadingOffset: CGFloat = 20
        static let longitudeTextFieldHeight: CGFloat = 40
        static let datePickerTopOffset: CGFloat = 10
        static let datePickerHeight: CGFloat = 40
        static let datePickerWidth: CGFloat = 140
        static let datePickerTrailingOffset: CGFloat = 20
        static let shadowOffset: CGSize = CGSize(width: 0, height: -10)
        static let shadowRadius: CGFloat = 10
        static let shadowOpacity: Float = 0.06
    }
}

public final class SolarLocationView: View {
    private lazy var backgroundView = View()
    private lazy var locationHeaderLabel = StyledLabel()
    private lazy var dateHeaderLabel = StyledLabel()
    private lazy var locationButton = PushButton(contentSize: .default)

    private lazy var latitudeTextField: RoundedFloatingTextField = {
        let view = RoundedFloatingTextField()
        view.delegate = self
        view.cornerRadius = Constants.fieldCornerRadius
        view.edgeInsets = Constants.defaultEdgeInsets
        view.isCopyButtonHidden = true
        return view
    }()

    private lazy var longitudeTextField: RoundedFloatingTextField = {
        let view = RoundedFloatingTextField()
        view.delegate = self
        view.cornerRadius = Constants.fieldCornerRadius
        view.edgeInsets = Constants.defaultEdgeInsets
        view.isCopyButtonHidden = true
        return view
    }()
    
    private lazy var datePicker: RoundedDatePicker = {
        let view = RoundedDatePicker()
        view.cornerRadius = Constants.fieldCornerRadius
        view.edgeInsets = Constants.defaultEdgeInsets
        return view
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
    
    public override func layout() {
        super.layout()

        let path = NSBezierPath(roundedRect: bounds, xRadius: Constants.contentCornerRadius, yRadius: Constants.contentCornerRadius)
        shadowLayer.bounds = bounds
        shadowLayer.shadowPath = path.path
    }
    
    // MARK: - Setup

    private func setup() {
        setupView()
        setupActions()
        setupConstraints()
    }

    private func setupView() {
        wantsLayer = true
        layer?.masksToBounds = false
        layer?.insertSublayer(shadowLayer, at: 0)
        
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = Constants.contentCornerRadius
        backgroundView.layer?.borderWidth = Constants.contentBorderWidth

        addSubview(backgroundView)
        addSubview(locationHeaderLabel)
        addSubview(dateHeaderLabel)
        addSubview(latitudeTextField)
        addSubview(longitudeTextField)
        addSubview(datePicker)
        addSubview(locationButton)
    }

    private func setupActions() {
        locationButton.onAction = { [weak self] button in
            self?.locationAction?(button)
        }
    }

    private func setupConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        locationHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        dateHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        latitudeTextField.translatesAutoresizingMaskIntoConstraints = false
        longitudeTextField.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        locationButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            locationHeaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.locationHeaderLabelLeadingOffset),
            locationHeaderLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.locationHeaderLabelTopOffset),

            dateHeaderLabel.leadingAnchor.constraint(equalTo: locationButton.trailingAnchor, constant: Constants.dateHeaderLabelLeadingOffset),
            dateHeaderLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.dateHeaderLabelTopOffset),
            
            locationButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.locationButtonTopOffset),
            locationButton.trailingAnchor.constraint(equalTo: longitudeTextField.trailingAnchor),
            locationButton.widthAnchor.constraint(equalToConstant: Constants.locationButtonWidth),
            locationButton.heightAnchor.constraint(equalToConstant: Constants.locationButtonHeight),
            
            latitudeTextField.topAnchor.constraint(equalTo: locationHeaderLabel.bottomAnchor, constant: Constants.latitudeTextFieldTopOffset),
            latitudeTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.latitudeTextFieldLeadingOffset),
            latitudeTextField.heightAnchor.constraint(equalToConstant: Constants.latitudeTextFieldHeight),
            latitudeTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Constants.latitudeTextFieldWidthMultiplier),
            latitudeTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.latitudeTextFieldBottomOffset),
            
            longitudeTextField.topAnchor.constraint(equalTo: locationHeaderLabel.bottomAnchor, constant: Constants.longitudeTextFieldTopOffset),
            longitudeTextField.leadingAnchor.constraint(
                equalTo: latitudeTextField.trailingAnchor,
                constant: Constants.longitudeTextFieldLeadingOffset
            ),
            longitudeTextField.heightAnchor.constraint(equalToConstant: Constants.longitudeTextFieldHeight),
            longitudeTextField.widthAnchor.constraint(equalTo: latitudeTextField.widthAnchor),

            datePicker.topAnchor.constraint(equalTo: dateHeaderLabel.bottomAnchor, constant: Constants.datePickerTopOffset),
            datePicker.leadingAnchor.constraint(equalTo: dateHeaderLabel.leadingAnchor),
            datePicker.widthAnchor.constraint(equalToConstant: Constants.datePickerWidth),
            datePicker.heightAnchor.constraint(equalToConstant: Constants.datePickerHeight),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.datePickerTrailingOffset)
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

    public var latitude: String? {
        didSet {
            latitudeTextField.text = latitude ?? String()
        }
    }

    public var longitude: String? {
        didSet {
            longitudeTextField.text = longitude ?? String()
        }
    }

    public var locationHeaderTitle: String? {
        didSet {
            locationHeaderLabel.stringValue = locationHeaderTitle ?? String()
        }
    }

    public var timeHeaderTitle: String? {
        didSet {
            dateHeaderLabel.stringValue = timeHeaderTitle ?? String()
        }
    }

    public var latitudeTitle: String? {
        didSet {
            latitudeTextField.title = latitudeTitle ?? String()
        }
    }

    public var longitudeTitle: String? {
        didSet {
            longitudeTextField.title = longitudeTitle ?? String()
        }
    }

    public var dateTitle: String? {
        didSet {
            datePicker.title = dateTitle ?? String()
        }
    }

    public var latitudePlaceholder: String? {
        didSet {
            latitudeTextField.placeholder = latitudePlaceholder ?? String()
        }
    }

    public var longitudePlaceholder: String? {
        didSet {
            longitudeTextField.placeholder = latitudePlaceholder ?? String()
        }
    }

    public var date: Date? {
        didSet {
            datePicker.date = date
        }
    }

    public var dateChangeAction: DateChangeAction? {
        didSet {
            datePicker.onDateChange = { [weak self] picker in
                self?.dateChangeAction?(picker.dateValue)
            }
        }
    }

    public var locationAction: ButtonAction?

    public var latitudeChangeAction: LatitudeChangeAction?

    public var longitudeChangeAction: LongitudeChangeAction?

    // MARK: - Private

    private func stylize() {
        locationHeaderLabel.style = style?.locationHeaderStyle
        dateHeaderLabel.style = style?.dateHeaderStyle
        latitudeTextField.style = style?.textFieldStyle
        longitudeTextField.style = style?.textFieldStyle
        datePicker.style = style?.datePickerStyle
        locationButton.style = style?.pushButtonStyle
        locationButton.image = style?.ownStyle.locationImage

        backgroundView.layer?.backgroundColor = style?.ownStyle.contentBackgroundColor.cgColor
        backgroundView.layer?.borderColor = style?.ownStyle.contentBackgroundBorderColor.cgColor
    }
}

// MARK: - RoundedFloatingTextFieldDelegate

extension SolarLocationView: RoundedFloatingTextFieldDelegate {
    public func textDidChange(_ textField: RoundedFloatingTextField) {
        switch textField {
        case longitudeTextField:
            longitudeChangeAction?(textField.text)

        case latitudeTextField:
            latitudeChangeAction?(textField.text)

        default:
            break
        }
    }
}
