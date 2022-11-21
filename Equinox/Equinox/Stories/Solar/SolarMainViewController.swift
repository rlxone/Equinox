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
import CoreLocation
import EquinoxAssets
import EquinoxCore
import EquinoxUI

// MARK: - Protocols

protocol SolarMainViewControllerDelegatae: AnyObject {
    func solarViewControllerShouldNotify(_ text: String)
    func solarViewControllerHelpWasInteracted()
}

// MARK: - Enums, Structs

extension SolarMainViewController {
    struct LocationCoordinate {
        var latitude: String?
        var longitude: String?
    }

    private enum Constants {
        static let solarDragType = NSPasteboard.PasteboardType("com.equinox.drag.solar")
        static let zoomFactor: Double = 0.005
        static let defaultTimeProgress: Float = 0.25
        static let resultPrecision = 2
        static let coordinatePrecision = 3
        static let hours = 24
    }
}

// MARK: - Class

final class SolarMainViewController: ViewController {
    private let solarService: SolarService

    private lazy var locationManager = CLLocationManager()
    private lazy var timezoneController = SolarTimezoneController()

    private var latestUserLocation: CLLocation?
    private var latestCoordinate = LocationCoordinate(latitude: nil, longitude: nil)
    private var latestDate = Date()
    private var latestTimeProgress = Constants.defaultTimeProgress
    private lazy var latestTimezoneContainer = timezoneController.currentContainer

    private var shouldIgnoreCoordinateChanges = false

    private lazy var contentView: SolarMainContentView = {
        let view = SolarMainContentView()
        view.style = .default
        view.chartDelegate = self
        return view
    }()

    // MARK: - Initializer

    init(solarService: SolarService) {
        self.solarService = solarService
        super.init()
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupActions()
        setupChartData()
    }

    private func setupView() {
        contentView.resultDelegate = self
        contentView.locationHeaderTitle = Localization.Solar.Main.locationHeader
        contentView.timeHeaderTitle = Localization.Solar.Main.dateHeader
        contentView.resultHeaderTitle = Localization.Solar.Main.resultHeader
        contentView.latitudeTitle = Localization.Solar.Main.latitude
        contentView.longitudeTitle = Localization.Solar.Main.longitude
        contentView.dateTitle = Localization.Solar.Main.date
        contentView.altitudeTitle = Localization.Solar.Main.altitude
        contentView.azimuthTitle = Localization.Solar.Main.azimuth
        contentView.fieldPlaceholder = Localization.Solar.Main.value
        contentView.timelineHeaderTitle = Localization.Solar.Main.sunTimeline
        contentView.timezoneHeaderTitle = Localization.Solar.Main.timezone
        contentView.date = latestDate
        contentView.timezoneData = SubMenuPopUpButton.MenuData(
            items: timezoneController.timezones,
            selectedItem: latestTimezoneContainer.name
        )
    }

    private func setupActions() {
        contentView.locationAction = { [weak self] _ in
            self?.requestLocation()
        }

        contentView.coordinateChangeAction = { [weak self] coordinate in
            self?.coordinateChangeAction(coordinate)
        }

        contentView.latitudeChangeAction = { [weak self] latitude in
            self?.latitudeChangeAction(latitude)
        }

        contentView.longitudeChangeAction = { [weak self] longitude in
            self?.longitudeChangeAction(longitude)
        }

        contentView.dateChangeAction = { [weak self] date in
            self?.dateChangeAction(date)
        }

        contentView.copyAction = { [weak self] _ in
            self?.copyAction()
        }

        contentView.helpAction = { [weak self] _ in
            self?.delegate?.solarViewControllerHelpWasInteracted()
        }

        contentView.timezoneChangeAction = { [weak self] timezone in
            self?.timezoneChangeAction(timezone)
        }
    }

    private func setupChartData() {
        reloadChartData()
        contentView.chartProgress = CGFloat(latestTimeProgress)
    }

    // MARK: - Public

    public weak var delegate: SolarMainViewControllerDelegatae?

    // MARK: - Private

    private func coordinateChangeAction(_ coordinate: CLLocationCoordinate2D) {
        guard !shouldIgnoreCoordinateChanges else {
            shouldIgnoreCoordinateChanges = false
            return
        }
        latestCoordinate.latitude = String(coordinate.latitude)
        latestCoordinate.longitude = String(coordinate.longitude)
        makeResult(needUpdateCoordinateFields: true, needRoundCoordinateValues: true)
    }

    private func latitudeChangeAction(_ latitude: String) {
        shouldIgnoreCoordinateChanges = true
        latestCoordinate.latitude = latitude
        makeResult(needUpdateCoordinateFields: false, needRoundCoordinateValues: false)
        setMapLocation(animated: false)
    }

    private func longitudeChangeAction(_ longitude: String) {
        shouldIgnoreCoordinateChanges = true
        latestCoordinate.longitude = longitude
        makeResult(needUpdateCoordinateFields: false, needRoundCoordinateValues: false)
        setMapLocation(animated: false)
    }

    private func dateChangeAction(_ date: Date) {
        latestDate = date
        makeResult(needUpdateCoordinateFields: true, needRoundCoordinateValues: true)
    }

    private func copyAction() {
        delegate?.solarViewControllerShouldNotify(Localization.Solar.Main.copied)
    }

    private func timezoneChangeAction(_ timezone: String) {
        latestTimezoneContainer = timezoneController.findContainer(name: timezone)
        makeResult(needUpdateCoordinateFields: false, needRoundCoordinateValues: false)
    }

    private func requestLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if let latestLocation = latestUserLocation {
            contentView.setMapLocation(latestLocation, animated: false)
        } else {
            locationManager.requestLocation()
        }
    }

    private func makeResult(needUpdateCoordinateFields: Bool, needRoundCoordinateValues: Bool) {
        guard
            let latitudeString = latestCoordinate.latitude,
            let longitudeString = latestCoordinate.longitude,
            let latitude = Double(latitudeString),
            let longitude = Double(longitudeString)
        else {
            shouldIgnoreCoordinateChanges = false
            contentView.azimuth = String()
            contentView.altitude = String()
            return
        }

        guard isLatitudeValid(latitude), isLongitudeValid(longitude) else {
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        if needUpdateCoordinateFields {
            if needRoundCoordinateValues {
                let roundedLatitude = roundDouble(coordinate.latitude, places: Constants.coordinatePrecision)
                let roundedLongitude = roundDouble(coordinate.longitude, places: Constants.coordinatePrecision)

                contentView.latitude = String(roundedLatitude)
                contentView.longitude = String(roundedLongitude)
            } else {
                contentView.latitude = String(coordinate.latitude)
                contentView.longitude = String(coordinate.longitude)
            }
        }

        guard let solarCoordinate = calculateSolarCoordinates(from: coordinate) else {
            return
        }

        let azimuth = roundDouble(solarCoordinate.azimuth, places: Constants.resultPrecision)
        let altitude = roundDouble(solarCoordinate.altitude, places: Constants.resultPrecision)

        contentView.azimuth = String(azimuth)
        contentView.altitude = String(altitude)

        reloadChartData()
    }

    private func setMapLocation(animated: Bool) {
        guard
            let latitudeString = latestCoordinate.latitude,
            let longitudeString = latestCoordinate.longitude,
            let latitude = Double(latitudeString),
            let longitude = Double(longitudeString),
            isLatitudeValid(latitude),
            isLongitudeValid(longitude)
        else {
            return
        }
        let location = CLLocation(latitude: latitude, longitude: longitude)
        contentView.setMapLocation(location, animated: false)
    }

    private func isLatitudeValid(_ latitude: Double) -> Bool {
        let lowerbound: Double = 90
        return latitude <= lowerbound && latitude >= -lowerbound
    }

    private func isLongitudeValid(_ longitude: Double) -> Bool {
        let lowerbound: Double = 180
        return longitude <= lowerbound && longitude >= -lowerbound
    }

    private func roundDouble(_ value: Double, places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(value * divisor) / divisor
    }

    private func calculateSolarCoordinates(from coordinate: CLLocationCoordinate2D) -> (azimuth: Double, altitude: Double)? {
        let latestTimezone = latestTimezoneContainer.timezone
        let timezone: Int = convertToHours(seconds: latestTimezone.secondsFromGMT())
        let daySavingTime = latestTimezone.isDaylightSavingTime(for: latestDate) ? 1 : 0
        let mergedDate = timezoneController.merge(date: latestDate, timeOffset: latestTimeProgress)

        guard
            let azimuth = try? solarService.azimuth(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                date: mergedDate ?? Date(),
                timezone: timezone,
                dlstime: daySavingTime
            ),
            let altitude = try? solarService.altitude(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                date: mergedDate ?? Date(),
                timezone: timezone,
                dlstime: daySavingTime
            )
        else {
            return nil
        }

        return (azimuth, altitude)
    }

    private func reloadChartData() {
        let calendar = timezoneController.calendar

        let startTime = calendar.startOfDay(for: latestDate)
        var chartData: [InteractiveLineChart.ChartData] = []

        for index in 0...Constants.hours {
            guard let time = calendar.date(byAdding: .hour, value: index, to: startTime) else {
                continue
            }

            var timeString: String
            let hour = index + 1

            if !hour.isMultiple(of: 2) {
                let progress: Float = Float(index) / Float(Constants.hours)
                timeString = timezoneController.compactTime(from: progress)
            } else {
                timeString = String()
            }

            let latitude = Double(latestCoordinate.latitude ?? String(0))
            let longitude = Double(latestCoordinate.longitude ?? String(0))
            let latestTimezone = latestTimezoneContainer.timezone
            let timezone = convertToHours(seconds: latestTimezone.secondsFromGMT())
            let daySavingTime = latestTimezone.isDaylightSavingTime(for: latestDate) ? 1 : 0

            do {
                let elevation = try solarService.altitude(
                    latitude: latitude ?? 0,
                    longitude: longitude ?? 0,
                    date: time,
                    timezone: timezone,
                    dlstime: daySavingTime
                )
                chartData.append(.init(bottomText: timeString, value: CGFloat(elevation)))
            } catch {
                continue
            }
        }

        contentView.chartData = chartData
    }

    private func convertToHours(seconds: Int) -> Int {
        return seconds / 60 / 60
    }
}

// MARK: - CLLocationManagerDelegate

extension SolarMainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        if latestUserLocation == nil {
            contentView.setMapLocation(location, animated: false)
            contentView.setMapZoomFactor(Constants.zoomFactor, animated: false)
        }
        latestUserLocation = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if latestUserLocation == nil {
            delegate?.solarViewControllerShouldNotify(Localization.Solar.Main.locationError)
        }
    }
}

// MARK: - SolarResultViewDelegate

extension SolarMainViewController: SolarResultViewDelegate {
    func beginDraggingSession(in view: SolarResultView, with event: NSEvent) {
        let object = [view.azimuth, view.altitude]
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false) else {
            return
        }

        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setData(data, forType: Constants.solarDragType)

        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame(view.bounds, contents: view.snapshot())
        view.beginDraggingSession(with: [draggingItem], event: event, source: self)
    }
}

// MARK: - NSDraggingSource

extension SolarMainViewController: NSDraggingSource {
    public func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        switch context {
        case .outsideApplication:
            return .init()

        case .withinApplication:
            return .generic

        @unknown default:
            return .init()
        }
    }
}

// MARK: - InteractiveLineChartDelegate

extension SolarMainViewController: InteractiveLineChartDelegate {
    func progressDidChange(progress: CGFloat) {
        latestTimeProgress = Float(progress)
        makeResult(needUpdateCoordinateFields: false, needRoundCoordinateValues: false)
    }

    func progressTitle(progress: CGFloat) -> String {
        return timezoneController.compactTime(from: Float(progress))
    }
}
