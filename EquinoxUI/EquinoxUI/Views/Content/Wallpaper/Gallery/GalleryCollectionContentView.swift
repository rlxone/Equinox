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

public protocol GalleryCollectionContentViewDelegate: AnyObject {
    func registerForDraggedTypes(_ view: GalleryCollectionContentView)
    func draggingEntered(_ view: GalleryCollectionContentView, sender: NSDraggingInfo) -> NSDragOperation
    func performDragOperation(_ view: GalleryCollectionContentView, sender: NSDraggingInfo) -> Bool
}

// MARK: - Enums, Structs

extension GalleryCollectionContentView {
    public struct Style {
        let galleryDragStyle: GalleryCollectionImageView.Style
        let buttonsStyle: GalleryCollectionButtonsView.Style
        let coordinatesStyle: GalleryCollectionCoordinatesView.Style
        let timeStyle: GalleryCollectionTimeView.Style
        let tooltipStyle: TooltipWindow.Style

        public init(
            galleryDragStyle: GalleryCollectionImageView.Style,
            buttonsStyle: GalleryCollectionButtonsView.Style,
            coordinatesStyle: GalleryCollectionCoordinatesView.Style,
            timeStyle: GalleryCollectionTimeView.Style,
            tooltipStyle: TooltipWindow.Style
        ) {
            self.galleryDragStyle = galleryDragStyle
            self.buttonsStyle = buttonsStyle
            self.coordinatesStyle = coordinatesStyle
            self.timeStyle = timeStyle
            self.tooltipStyle = tooltipStyle
        }
    }
    
    static let imageAspect: CGFloat = 9 / 16

    private enum Constants {
        static let defaultPadding: CGFloat = 10
        static let appearancePadding: CGFloat = 12
        static let buttonStackWidth: CGFloat = 40
        static let buttonStackHeight: CGFloat = 72
        static let timeStackHeight: CGFloat = 40
    }
}

// MARK: - Class

public final class GalleryCollectionContentView: View {
    private lazy var imageView = GalleryCollectionImageView()
    private weak var dataView: View?
    private lazy var tooltipHandler = GalleryCollectionTooltipHandler()
    
    private lazy var buttonsView: GalleryCollectionButtonsView = {
        let view = GalleryCollectionButtonsView()
        view.tooltipDelegate = tooltipHandler
        return view
    }()
    
    // MARK: - Life Cycle

    public override var wantsUpdateLayer: Bool {
        return true
    }

    public override func updateLayer() {
        super.updateLayer()
        stylize()
    }

    public override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        isHiglighted = true
        return delegate?.draggingEntered(self, sender: sender) ?? .init()
    }

    public override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return delegate?.performDragOperation(self, sender: sender) ?? false
    }

    public override func draggingEnded(_ sender: NSDraggingInfo) {
        isHiglighted = false
    }
    
    public override func draggingExited(_ sender: NSDraggingInfo?) {
        isHiglighted = false
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
    }

    private func setupView() {
        addSubview(imageView)
        addSubview(buttonsView)

        switch collectionType {
        case .solar, .none:
            setupSolarView()

        case .time:
            setupTimeView()

        case .appearance:
            setupAppearanceView()
        }
    }

    private func setupSolarView() {
        buttonsView.orientation = .vertical
        buttonsView.viewAppearance = .default
        imageView.viewAppearance = .default
        imageView.size = .small
        imageView.position = .bottomLeft
        let coordinatesView = GalleryCollectionCoordinatesView()
        addSubview(coordinatesView)
        dataView = coordinatesView
    }

    private func setupTimeView() {
        buttonsView.orientation = .horizontal
        buttonsView.viewAppearance = .default
        imageView.viewAppearance = .default
        imageView.size = .small
        imageView.position = .bottomLeft
        let timeView = GalleryCollectionTimeView()
        addSubview(timeView)
        dataView = timeView
    }

    private func setupAppearanceView() {
        buttonsView.orientation = .vertical
        buttonsView.viewAppearance = .vibrant
        imageView.viewAppearance = .vibrant
        imageView.size = .normal
        imageView.position = .topLeft
    }
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        dataView?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: GalleryCollectionContentView.imageAspect)
        ])

        switch collectionType {
        case .none, .solar:
            setupSolarConstraints()

        case .time:
            setupTimeConstraints()

        case .appearance:
            setupAppearanceConstraints()
        }
    }

    private func setupSolarConstraints() {
        NSLayoutConstraint.activate([
            buttonsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.defaultPadding),
            buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsView.widthAnchor.constraint(equalToConstant: Constants.buttonStackWidth),
            buttonsView.heightAnchor.constraint(equalToConstant: Constants.buttonStackHeight)
        ])

        if let dataView = dataView {
            NSLayoutConstraint.activate([
                dataView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.defaultPadding),
                dataView.leadingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: Constants.defaultPadding),
                dataView.trailingAnchor.constraint(equalTo: trailingAnchor),
                dataView.heightAnchor.constraint(equalToConstant: Constants.buttonStackHeight)
            ])
        }
    }
    
    private func setupTimeConstraints() {
        NSLayoutConstraint.activate([
            buttonsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.defaultPadding),
            buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsView.widthAnchor.constraint(equalToConstant: Constants.buttonStackHeight),
            buttonsView.heightAnchor.constraint(equalToConstant: Constants.buttonStackWidth)
        ])

        if let dataView = dataView {
            NSLayoutConstraint.activate([
                dataView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.defaultPadding),
                dataView.leadingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: Constants.defaultPadding),
                dataView.trailingAnchor.constraint(equalTo: trailingAnchor),
                dataView.heightAnchor.constraint(equalToConstant: Constants.timeStackHeight)
            ])
        }
    }
    
    private func setupAppearanceConstraints() {
        NSLayoutConstraint.activate([
            buttonsView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -Constants.appearancePadding),
            buttonsView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: Constants.appearancePadding),
            buttonsView.widthAnchor.constraint(equalToConstant: Constants.buttonStackWidth),
            buttonsView.heightAnchor.constraint(equalToConstant: Constants.buttonStackHeight)
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
    
    public weak var delegate: GalleryCollectionContentViewDelegate? {
        didSet {
            delegate?.registerForDraggedTypes(self)
        }
    }
    
    public var collectionType: GalleryCollectionView.CollectionType? {
        didSet {
            guard oldValue != collectionType else {
                return
            }
            for subview in subviews {
                subview.removeFromSuperview()
            }
            setup()
        }
    }
    
    public var number: Int? {
        didSet {
            imageView.number = number
        }
    }

    public var isHiglighted: Bool {
        get {
            return imageView.isHiglighted
        }
        set {
            imageView.isHiglighted = newValue
        }
    }

    public var isPrimary: Bool {
        get {
            return buttonsView.isPrimary
        }
        set {
            buttonsView.isPrimary = newValue
        }
    }
    
    public var image: NSImage? {
        didSet {
            imageView.image = image
        }
    }
    
    public func setAppearanceType(_ appearanceType: AppearanceType, animated: Bool) {
        buttonsView.setAppearanceType(appearanceType, animated: animated)
    }
    
    public func flash() {
        coordinatesDataView?.flash()
    }
    
    public var azimuth: String? {
        didSet {
            coordinatesDataView?.azimuth = azimuth
        }
    }

    public var altitude: String? {
        didSet {
            coordinatesDataView?.altitude = altitude
        }
    }
    
    public var time: Date? {
        didSet {
            timeDataView?.time = time
        }
    }

    public var altitudeText: String? {
        didSet {
            coordinatesDataView?.altitudeText = altitudeText
        }
    }

    public var altitudePlaceholder: String? {
        didSet {
            coordinatesDataView?.altitudePlaceholder = altitudePlaceholder
        }
    }

    public var azimuthText: String = String() {
        didSet {
            coordinatesDataView?.azimuthText = azimuthText
        }
    }

    public var azimuthPlaceholder: String? {
        didSet {
            coordinatesDataView?.azimuthPlaceholder = azimuthPlaceholder
        }
    }

    public var timeText: String = String() {
        didSet {
            timeDataView?.timeText = timeText
        }
    }

    public var onAzimuthChange: GalleryCollectionCoordinatesView.FloatingChangeAction? {
        didSet {
            coordinatesDataView?.onAzimuthChange = onAzimuthChange
        }
    }
    
    public var onAltitudeChange: GalleryCollectionCoordinatesView.FloatingChangeAction? {
        didSet {
            coordinatesDataView?.onAltitudeChange = onAltitudeChange
        }
    }

    public var onTimeChange: GalleryCollectionTimeView.TimeChangeAction? {
        didSet {
            timeDataView?.onTimeChange = onTimeChange
        }
    }
    
    public var onPrimaryChange: GalleryCollectionButtonsView.PrimaryChangeAction? {
        didSet {
            buttonsView.onPrimaryChange = onPrimaryChange
        }
    }
    
    public var onAppearanceTypeChange: GalleryCollectionButtonsView.AppearanceTypeChangeAction? {
        didSet {
            buttonsView.onAppearanceTypeChange = onAppearanceTypeChange
        }
    }
    
    public var appearanceTooltipTitle: String? {
        didSet {
            tooltipHandler.appearanceTooltipTitle = appearanceTooltipTitle
        }
    }
    
    public var appearanceTooltipDescription: String? {
        didSet {
            tooltipHandler.appearanceTooltipDescription = appearanceTooltipDescription
        }
    }
    
    public var primaryTooltipTitle: String? {
        didSet {
            tooltipHandler.primaryTooltipTitle = primaryTooltipTitle
        }
    }
    
    public var primaryTooltipDescription: String? {
        didSet {
            tooltipHandler.primaryTooltipDescription = primaryTooltipDescription
        }
    }
    
    // MARK: - Private
    
    private var coordinatesDataView: GalleryCollectionCoordinatesView? {
        return dataView as? GalleryCollectionCoordinatesView
    }
    
    private var timeDataView: GalleryCollectionTimeView? {
        return dataView as? GalleryCollectionTimeView
    }
    
    private func stylize() {
        imageView.style = style?.galleryDragStyle
        buttonsView.style = style?.buttonsStyle
        tooltipHandler.style = style?.tooltipStyle
        
        guard let collectionType = collectionType else {
            return
        }

        switch collectionType {
        case .solar:
            coordinatesDataView?.style = style?.coordinatesStyle
            
        case .time:
            timeDataView?.style = style?.timeStyle

        case .appearance:
            break
        }
    }
}
