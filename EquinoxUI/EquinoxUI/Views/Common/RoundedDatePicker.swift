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

extension RoundedDatePicker {
    public typealias DateChangeAction = (NSDatePicker) -> Void

    public struct Style {
        let backgroundColor: NSColor
        let borderColor: NSColor
        let textFont: NSFont
        let textColor: NSColor

        public init(
            backgroundColor: NSColor,
            borderColor: NSColor,
            textFont: NSFont,
            textColor: NSColor
        ) {
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.textFont = textFont
            self.textColor = textColor
        }
    }
    
    private enum Constants {
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let spacerHeight: CGFloat = 3
        static let shadowOffset: CGSize = CGSize(width: 0, height: -10)
        static let shadowRadius: CGFloat = 10
        static let shadowOpacity: Float = 0.06
    }
}

// MARK: - Class

public final class RoundedDatePicker: View {
    private lazy var backgroundView = View()
    private lazy var titleLabel = Label()

    private lazy var datePicker: NSDatePicker = {
        let picker = NSDatePicker()
        picker.isBordered = false
        picker.datePickerMode = .single
        picker.datePickerElements = [.yearMonthDay]
        picker.datePickerStyle = .textField
        picker.backgroundColor = .clear
        picker.focusRingType = .none
        picker.timeZone = TimeZone(identifier: "GMT")
        picker.calendar = nil
        if #available(macOS 10.15.4, *) {
            picker.presentsCalendarOverlay = true
        }
        return picker
    }()

    private lazy var stackView: StackView = {
        let stackView = StackView()
        stackView.spacing = Constants.cornerRadius
        return stackView
    }()

    private lazy var spacerView = View()
    
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
    
    public override func layout() {
        super.layout()

        let path = NSBezierPath(roundedRect: bounds, xRadius: cornerRadius, yRadius: cornerRadius)
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
        backgroundView.layer?.borderWidth = Constants.borderWidth

        addSubview(backgroundView)
        addSubview(stackView)

        let dateStackView = StackView()
        dateStackView.orientation = .vertical
        dateStackView.alignment = .left
        dateStackView.distribution = .fill
        dateStackView.spacing = 0
        dateStackView.addView(spacerView, in: .leading)
        dateStackView.addView(datePicker, in: .leading)

        stackView.addView(titleLabel, in: .leading)
        stackView.addView(dateStackView, in: .leading)
    }

    private func setupConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            spacerView.heightAnchor.constraint(equalToConstant: Constants.spacerHeight)
        ])
    }

    private func setupActions() {
        datePicker.target = self
        datePicker.action = #selector(dateAction)
    }
    
    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var cornerRadius: CGFloat = 0 {
        didSet {
            needsLayout = true
            backgroundView.layer?.cornerRadius = cornerRadius
        }
    }

    public var edgeInsets: NSEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            stackView.edgeInsets = edgeInsets
        }
    }

    public var title: String? {
        didSet {
            titleLabel.stringValue = title ?? String()
        }
    }

    public var date: Date? {
        didSet {
            datePicker.dateValue = date ?? Date()
        }
    }

    public var onDateChange: DateChangeAction?
    
    // MARK: - Private
    
    private func stylize() {
        backgroundView.layer?.backgroundColor = style?.backgroundColor.cgColor
        backgroundView.layer?.borderColor = style?.borderColor.cgColor
        titleLabel.font = style?.textFont
        titleLabel.textColor = style?.textColor
        datePicker.font = style?.textFont
        if let color = style?.textColor {
            datePicker.textColor = color
        }
    }

    @objc
    private func dateAction() {
        onDateChange?(datePicker)
    }
}
