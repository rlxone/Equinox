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
import MapKit

// MARK: - Enums, Structs

extension SolarMainContentView {
    public typealias CoordinateChangeAction = (CLLocationCoordinate2D) -> Void
    public typealias HelpAction = (NSButton) -> Void

    public struct Style {
        public struct OwnStyle {
            let pinImage: NSImage

            public init(pinImage: NSImage) {
                self.pinImage = pinImage
            }
        }

        let ownStyle: OwnStyle
        let locationStyle: SolarLocationView.Style
        let timelineStyle: SolarTimelineView.Style
        let resultStyle: SolarResultView.Style
        let lineStyle: LineView.Style
        let tooltipStyle: TooltipWindow.Style

        public init(
            ownStyle: OwnStyle,
            locationStyle: SolarLocationView.Style,
            timelineStyle: SolarTimelineView.Style,
            resultStyle: SolarResultView.Style,
            lineStyle: LineView.Style,
            tooltipStyle: TooltipWindow.Style
        ) {
            self.ownStyle = ownStyle
            self.locationStyle = locationStyle
            self.timelineStyle = timelineStyle
            self.resultStyle = resultStyle
            self.lineStyle = lineStyle
            self.tooltipStyle = tooltipStyle
        }
    }

    private enum Constants {
        static let lineHeight: CGFloat = 1
        static let locationTopOffset: CGFloat = 30
        static let locationLeadingOffset: CGFloat = 20
        static let locationTrailingOffset: CGFloat = 20
        static let solarTimelineTopOffset: CGFloat = 20
        static let solarTimelineLeadingOffset: CGFloat = 20
        static let solarTimelineTrailingOffset: CGFloat = 20
        static let resultTopOffset: CGFloat = 20
        static let resultLeadingOffset: CGFloat = 20
        static let resultTrailingOffset: CGFloat = 20
        static let pinCenterXOffset: CGFloat = 8
        static let pinCenterYOffset: CGFloat = 15
        static let pinWidth: CGFloat = 32
        static let pinHeight: CGFloat = 39
        static let helpTopOffset: CGFloat = 20
        static let helpTrailingOffset: CGFloat = 20
        static let helpBottomOffset: CGFloat = 20
    }
    
    enum TooltipIdentifier: String {
        case daylightSavingTime
        case abbreviation
        case dragAndDrop
    }
}

// MARK: - Class

public final class SolarMainContentView: VisualEffectView {
    private lazy var overlayView = View()
    private lazy var locationView = SolarLocationView()
    private lazy var resultView: SolarResultView = {
        let view = SolarResultView()
        view.tooltipDelegate = tooltipHandler
        return view
    }()
    private lazy var timelineView: SolarTimelineView = {
        let view = SolarTimelineView()
        view.tooltipDelegate = tooltipHandler
        return view
    }()
    private lazy var lineView = LineView()
    private lazy var tooltipHandler = SolarTooltipHander()
    
    private lazy var helpButton: NSButton = {
        let button = NSButton()
        button.bezelStyle = .helpButton
        button.title = String()
        button.action = #selector(helpButtonAction(_:))
        button.target = self
        return button
    }()

    private lazy var pinImageView: ImageView = {
        let imageView = ImageView()
        imageView.isUserInteractionsEnabled = false
        return imageView
    }()

    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsZoomControls = true
        mapView.showsTraffic = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsBuildings = true
        mapView.showsPointsOfInterest = true
        if #available(macOS 11, *) {
            mapView.showsPitchControl = true
        }
        if #available(macOS 14, *) {
            mapView.pitchButtonVisibility = .visible
        }
        mapView.delegate = self
        return mapView
    }()
    
    // MARK: - Initializer

    public init() {
        super.init(material: .windowBackground, blendingMode: .behindWindow)
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

    // MARK: - Public
    
    public var style: Style? {
        didSet {
            runWithEffectiveAppearance {
                stylize()
            }
        }
    }

    public weak var resultDelegate: SolarResultViewDelegate? {
        didSet {
            resultView.delegate = resultDelegate
        }
    }

    public var locationHeaderTitle: String? {
        didSet {
            locationView.locationHeaderTitle = locationHeaderTitle ?? String()
        }
    }

    public var timeHeaderTitle: String? {
        didSet {
            locationView.timeHeaderTitle = timeHeaderTitle ?? String()
        }
    }
    
    public var timelineHeaderTitle: String? {
        didSet {
            timelineView.timelineHeaderTitle = timelineHeaderTitle ?? String()
        }
    }
    
    public var timezoneData: SubMenuPopUpButton.MenuData? {
        didSet {
            timelineView.timezoneData = timezoneData
        }
    }
    
    public var timezoneAbbreviationTitle: String? {
        didSet {
            timelineView.timezoneAbbreviationTitle = timezoneAbbreviationTitle
        }
    }
    
    public var isTimezoneDaylightSavingTimeVisible: Bool {
        get {
            return timelineView.isTimezoneDaylightSavingTimeVisible
        }
        set {
            timelineView.isTimezoneDaylightSavingTimeVisible = newValue
        }
    }
    
    public var timezoneDaylightSavingTimeTitle: String? {
        didSet {
            timelineView.timezoneDaylightSavingTimeTitle = timezoneDaylightSavingTimeTitle
        }
    }
    
    public var timezoneChangeAction: SubMenuPopUpButton.ChangeAction? {
        didSet {
            timelineView.timezoneChangeAction = timezoneChangeAction
        }
    }
    
    public var resultHeaderTitle: String? {
        didSet {
            resultView.resultHeaderTitle = resultHeaderTitle ?? String()
        }
    }

    public var latitudeTitle: String? {
        didSet {
            locationView.latitudeTitle = latitudeTitle ?? String()
        }
    }

    public var longitudeTitle: String? {
        didSet {
            locationView.longitudeTitle = longitudeTitle ?? String()
        }
    }

    public var dateTitle: String? {
        didSet {
            locationView.dateTitle = dateTitle ?? String()
        }
    }

    public var altitudeTitle: String? {
        didSet {
            resultView.altitudeTitle = altitudeTitle ?? String()
        }
    }

    public var azimuthTitle: String? {
        didSet {
            resultView.azimuthTitle = azimuthTitle ?? String()
        }
    }

    public var latitude: String? {
        didSet {
            locationView.latitude = latitude ?? String()
        }
    }

    public var longitude: String? {
        didSet {
            locationView.longitude = longitude ?? String()
        }
    }

    public var date: Date? {
        didSet {
            locationView.date = date
        }
    }
    
    public var chartData: [InteractiveLineChart.ChartData]? {
        didSet {
            timelineView.chartData = chartData
        }
    }
    
    public weak var chartDelegate: InteractiveLineChartDelegate? {
        didSet {
            timelineView.chartDelegate = chartDelegate
        }
    }
    
    public var chartProgress: CGFloat? {
        didSet {
            timelineView.chartProgress = chartProgress ?? 0
        }
    }

    public var altitude: String? {
        didSet {
            resultView.altitude = altitude ?? String()
        }
    }

    public var azimuth: String? {
        didSet {
            resultView.azimuth = azimuth ?? String()
        }
    }

    public var fieldPlaceholder: String? {
        didSet {
            locationView.latitudePlaceholder = fieldPlaceholder
            locationView.longitudePlaceholder = fieldPlaceholder
            resultView.altitudePlaceholder = fieldPlaceholder
            resultView.azimuthPlaceholder = fieldPlaceholder
        }
    }

    public var coordinateChangeAction: CoordinateChangeAction?

    public var locationAction: SolarLocationView.ButtonAction? {
        didSet {
            locationView.locationAction = locationAction
        }
    }

    public var latitudeChangeAction: SolarLocationView.LatitudeChangeAction? {
        didSet {
            locationView.latitudeChangeAction = latitudeChangeAction
        }
    }

    public var longitudeChangeAction: SolarLocationView.LongitudeChangeAction? {
        didSet {
            locationView.longitudeChangeAction = longitudeChangeAction
        }
    }

    public var dateChangeAction: SolarLocationView.DateChangeAction? {
        didSet {
            locationView.dateChangeAction = dateChangeAction
        }
    }

    public var copyAction: RoundedFloatingTextField.CopyAction? {
        didSet {
            resultView.copyAction = copyAction
        }
    }
    
    public var helpAction: HelpAction?
    
    public var daylightSavingTimeTooltipTitle: String? {
        didSet {
            tooltipHandler.daylightSavingTimeTitle = daylightSavingTimeTooltipTitle
        }
    }
    
    public var daylightSavingTimeTooltipDescription: String? {
        didSet {
            tooltipHandler.daylightSavingTimeDescription = daylightSavingTimeTooltipDescription
        }
    }
    
    public var abbreviationTooltipTitle: String? {
        didSet {
            tooltipHandler.abbreviationTitle = abbreviationTooltipTitle
        }
    }
    
    public var abbreviationTooltipDescription: String? {
        didSet {
            tooltipHandler.abbreviationDescription = abbreviationTooltipDescription
        }
    }
    
    public var dragAndDropTooltipTitle: String? {
        didSet {
            tooltipHandler.dragAndDropTitle = dragAndDropTooltipTitle
        }
    }
    
    public var dragAndDropTooltipDescription: String? {
        didSet {
            tooltipHandler.dragAndDropDescription = dragAndDropTooltipDescription
        }
    }

    // MARK: - Private

    private func stylize() {
        locationView.style = style?.locationStyle
        timelineView.style = style?.timelineStyle
        resultView.style = style?.resultStyle
        lineView.style = style?.lineStyle
        pinImageView.image = style?.ownStyle.pinImage
        tooltipHandler.style = style?.tooltipStyle
    }
    
    @objc
    private func helpButtonAction(_ sender: NSButton) {
        helpAction?(sender)
    }
}

// MARK: - Setup

extension SolarMainContentView {
    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(mapView)
        addSubview(overlayView)
        addSubview(pinImageView)
        addSubview(helpButton)

        overlayView.addSubview(locationView)
        overlayView.addSubview(timelineView)
        overlayView.addSubview(resultView)
        overlayView.addSubview(lineView)
    }
    
    private func setupConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        locationView.translatesAutoresizingMaskIntoConstraints = false
        resultView.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        helpButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.bottomAnchor.constraint(equalTo: overlayView.topAnchor),

            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

            lineView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
            lineView.topAnchor.constraint(equalTo: overlayView.topAnchor),
            lineView.heightAnchor.constraint(equalToConstant: Constants.lineHeight),

            locationView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: Constants.locationTopOffset),
            locationView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: Constants.locationLeadingOffset),
            locationView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -Constants.locationTrailingOffset),
            
            timelineView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: Constants.solarTimelineLeadingOffset),
            timelineView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -Constants.solarTimelineTrailingOffset),
            timelineView.topAnchor.constraint(equalTo: locationView.bottomAnchor, constant: Constants.solarTimelineTopOffset),
            
            resultView.topAnchor.constraint(equalTo: timelineView.bottomAnchor, constant: Constants.resultTopOffset),
            resultView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: Constants.resultLeadingOffset),
            resultView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -Constants.resultTrailingOffset),
            
            pinImageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: Constants.pinCenterXOffset),
            pinImageView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -Constants.pinCenterYOffset),
            pinImageView.widthAnchor.constraint(equalToConstant: Constants.pinWidth),
            pinImageView.heightAnchor.constraint(equalToConstant: Constants.pinHeight),
            
            helpButton.topAnchor.constraint(equalTo: resultView.bottomAnchor, constant: Constants.helpTopOffset),
            helpButton.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -Constants.helpBottomOffset),
            helpButton.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -Constants.helpTrailingOffset)
        ])
    }
}

// MARK: - MKMapView, MKMapViewDelegate

extension SolarMainContentView: MKMapViewDelegate {
    public func setMapLocation(_ location: CLLocation, animated: Bool) {
        mapView.setCenter(location.coordinate, animated: animated)
    }
    
    public func setMapZoomFactor(_ factor: Double, animated: Bool) {
        let span = MKCoordinateSpan(latitudeDelta: factor, longitudeDelta: factor)
        let region = MKCoordinateRegion(center: mapView.centerCoordinate, span: span)
        mapView.setRegion(region, animated: animated)
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        coordinateChangeAction?(mapView.centerCoordinate)
    }
}
