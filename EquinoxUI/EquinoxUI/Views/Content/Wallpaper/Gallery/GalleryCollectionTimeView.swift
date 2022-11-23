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

extension GalleryCollectionTimeView {
    public typealias TimeChangeAction = (NSDatePicker) -> Void

    public struct Style {
        public struct OwnStyle {
            let stackBackgroundColor: NSColor
            let stackBorderColor: NSColor

            public init(stackBackgroundColor: NSColor, stackBorderColor: NSColor) {
                self.stackBackgroundColor = stackBackgroundColor
                self.stackBorderColor = stackBorderColor
            }
        }

        let ownStyle: OwnStyle
        let timeStyle: StyledLabel.Style

        public init(ownStyle: OwnStyle, timeStyle: StyledLabel.Style) {
            self.ownStyle = ownStyle
            self.timeStyle = timeStyle
        }
    }

    private enum Constants {
        static let cornerRadius: CGFloat = 4
        static let borderWidth: CGFloat = 1
        static let timePickerLeadingOffset: CGFloat = 4
        static let timeLabelLeadingOffset: CGFloat = 11
        static let timePickerCenterYOffset: CGFloat = 1.5
    }
}

// MARK: - Class

public final class GalleryCollectionTimeView: View {
    private lazy var timeLabel = StyledLabel()

    private lazy var timePicker: NSDatePicker = {
        let picker = NSDatePicker()
        picker.isBordered = false
        picker.datePickerMode = .single
        picker.datePickerElements = [.hourMinuteSecond]
        picker.datePickerStyle = .textField
        picker.backgroundColor = .clear
        picker.focusRingType = .none
        picker.timeZone = TimeZone(identifier: "GMT")
        picker.calendar = nil
        return picker
    }()
    
    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }
    
    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
        setupActions()
    }

    private func setupView() {
        wantsLayer = true
        layer?.borderWidth = Constants.borderWidth
        layer?.cornerRadius = Constants.cornerRadius
        
        addSubview(timeLabel)
        addSubview(timePicker)
    }

    private func setupConstraints() {
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timePicker.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.timeLabelLeadingOffset),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            timePicker.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: Constants.timePickerLeadingOffset),
            timePicker.centerYAnchor.constraint(equalTo: centerYAnchor, constant: Constants.timePickerCenterYOffset)
        ])
    }

    private func setupActions() {
        timePicker.target = self
        timePicker.action = #selector(timeAction)
    }
    
    // MARK: - Public

    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public var time: Date? {
        didSet {
            timePicker.dateValue = time ?? Date()
        }
    }

    public var timeText: String? {
        didSet {
            timeLabel.stringValue = timeText ?? String()
        }
    }

    public var onTimeChange: TimeChangeAction?
    
    // MARK: - Private
    
    private func stylize() {
        timeLabel.style = style?.timeStyle
        timePicker.font = style?.timeStyle.font

        layer?.backgroundColor = style?.ownStyle.stackBackgroundColor.cgColor
        layer?.borderColor = style?.ownStyle.stackBorderColor.cgColor
    }

    @objc
    private func timeAction() {
        onTimeChange?(timePicker)
    }
}
