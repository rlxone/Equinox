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

extension SolarTimelineView {
    public struct Style {
        public struct OwnStyle {
            let contentBackgroundColor: NSColor
            let contentBackgroundBorderColor: NSColor

            public init(
                contentBackgroundColor: NSColor,
                contentBackgroundBorderColor: NSColor
            ) {
                self.contentBackgroundColor = contentBackgroundColor
                self.contentBackgroundBorderColor = contentBackgroundBorderColor
            }
        }

        let ownStyle: OwnStyle
        let interactiveLineChartStyle: InteractiveLineChart.Style
        let titleStyle: StyledLabel.Style
        let timelineStyle: StyledLabel.Style

        public init(
            ownStyle: SolarTimelineView.Style.OwnStyle,
            interactiveLineChartStyle: InteractiveLineChart.Style,
            titleStyle: StyledLabel.Style,
            timelineStyle: StyledLabel.Style
        ) {
            self.ownStyle = ownStyle
            self.interactiveLineChartStyle = interactiveLineChartStyle
            self.titleStyle = titleStyle
            self.timelineStyle = timelineStyle
        }
    }

    private enum Constants {
        static let contentCornerRadius: CGFloat = 8
        static let contentBorderWidth: CGFloat = 1
        static let titleTopOffset: CGFloat = 16
        static let titleLeadingOffset: CGFloat = 20
        static let chartTopOffset: CGFloat = 10
        static let chartBottomOffset: CGFloat = 16
        static let chartHeightOffset: CGFloat = 148
        static let timezoneButtonTopOffset: CGFloat = 16
        static let timezoneButtonTrailingOffset: CGFloat = 25
        static let timezoneButtonWidth: CGFloat = 150
        static let timezoneLabelTrailingOffset: CGFloat = 8
        static let chartInsets = NSEdgeInsets(top: 14, left: 25, bottom: 14, right: 25)
    }
}

// MARK: - Class

public final class SolarTimelineView: View {
    private lazy var interactiveLineChart: InteractiveLineChart = {
        let chart = InteractiveLineChart()
        chart.chartInsets = Constants.chartInsets
        return chart
    }()
    private lazy var titleLabel = StyledLabel()
    private lazy var timezoneLabel = StyledLabel()
    private lazy var timezoneButton = SubMenuPopUpButton()

    // MARK: - Initializer

    public override init() {
        super.init()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = Constants.contentCornerRadius
        layer?.borderWidth = Constants.contentBorderWidth

        addSubview(titleLabel)
        addSubview(timezoneLabel)
        addSubview(interactiveLineChart)
        addSubview(timezoneButton)
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timezoneLabel.translatesAutoresizingMaskIntoConstraints = false
        interactiveLineChart.translatesAutoresizingMaskIntoConstraints = false
        timezoneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.titleLeadingOffset),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.titleTopOffset),

            interactiveLineChart.leadingAnchor.constraint(equalTo: leadingAnchor),
            interactiveLineChart.trailingAnchor.constraint(equalTo: trailingAnchor),
            interactiveLineChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.chartTopOffset),
            interactiveLineChart.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.chartBottomOffset),
            interactiveLineChart.heightAnchor.constraint(equalToConstant: Constants.chartHeightOffset),

            timezoneButton.topAnchor.constraint(equalTo: topAnchor, constant: Constants.timezoneButtonTopOffset),
            timezoneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.timezoneButtonTrailingOffset),
            timezoneButton.widthAnchor.constraint(equalToConstant: Constants.timezoneButtonWidth),

            timezoneLabel.trailingAnchor.constraint(equalTo: timezoneButton.leadingAnchor, constant: -Constants.timezoneLabelTrailingOffset),
            timezoneLabel.centerYAnchor.constraint(equalTo: timezoneButton.centerYAnchor)
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

    public weak var chartDelegate: InteractiveLineChartDelegate? {
        didSet {
            interactiveLineChart.delegate = chartDelegate
        }
    }

    public var chartData: [InteractiveLineChart.ChartData]? {
        didSet {
            interactiveLineChart.chartData = chartData
        }
    }

    public var chartProgress: CGFloat? {
        didSet {
            interactiveLineChart.progress = chartProgress ?? 0
        }
    }

    public var timelineHeaderTitle: String? {
        didSet {
            titleLabel.stringValue = timelineHeaderTitle ?? String()
        }
    }

    public var timezoneHeaderTitle: String? {
        didSet {
            timezoneLabel.stringValue = timezoneHeaderTitle ?? String()
        }
    }

    public var timezoneData: SubMenuPopUpButton.MenuData? {
        didSet {
            timezoneButton.data = timezoneData
        }
    }

    public var timezoneChangeAction: SubMenuPopUpButton.ChangeAction? {
        didSet {
            timezoneButton.changeAction = timezoneChangeAction
        }
    }

    // MARK: - Private

    private func stylize() {
        interactiveLineChart.style = style?.interactiveLineChartStyle
        titleLabel.style = style?.titleStyle
        timezoneLabel.style = style?.timelineStyle

        layer?.backgroundColor = style?.ownStyle.contentBackgroundColor.cgColor
        layer?.borderColor = style?.ownStyle.contentBackgroundBorderColor.cgColor
    }
}
