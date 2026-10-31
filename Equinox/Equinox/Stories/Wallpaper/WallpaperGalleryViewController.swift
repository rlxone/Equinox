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
import EquinoxAssets
import EquinoxCore
import EquinoxUI
import UniformTypeIdentifiers

private final class SelectionCountMenuItemView: NSView {
    private let titleField: NSTextField

    init(title: String) {
        titleField = NSTextField(labelWithString: title)
        super.init(frame: .zero)

        titleField.font = .systemFont(
            ofSize: NSFont.systemFontSize,
            weight: .semibold
        )
        titleField.textColor = .labelColor
        titleField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleField)

        NSLayoutConstraint.activate([
            titleField.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(
            width: titleField.fittingSize.width + 44,
            height: 24
        )
    }
}

// MARK: - Protocols

protocol WallpaperGalleryViewControllerDelegate: AnyObject {
    func dataWasChanged()
    func openBrowseDialog()
    func notify(_ text: String)
}

// MARK: - Enums, Structs

extension WallpaperGalleryViewController {
    private enum Constants {
        static let thumbnailSize = NSSize(width: 768, height: 425.25)
        static let maxAppearanceItemsCount = 2
    }
}

// MARK: - Class

final class WallpaperGalleryViewController: ViewController {
    private let type: WallpaperType
    private let solarService: SolarService
    private let fileService: FileService
    private let imageProvider: ImageProvider
    private lazy var dragController: WallpaperGalleryDragController = {
        let controller = WallpaperGalleryDragController(type: type)
        controller.delegate = self
        return controller
    }()
    private lazy var dataController = WallpaperGalleryDataController(
        type: type,
        solarService: solarService,
        imageProvider: imageProvider
    )
    
    private lazy var contentView: GalleryContentView = {
        let view = GalleryContentView()
        view.style = .default
        return view
    }()
    
    // MARK: - Initializer

    init(type: WallpaperType, solarService: SolarService, fileService: FileService, imageProvider: ImageProvider) {
        self.type = type
        self.solarService = solarService
        self.fileService = fileService
        self.imageProvider = imageProvider
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
    }
    
    private func setupView() {
        switch type {
        case .solar:
            contentView.collectionType = .solar

        case .time:
            contentView.collectionType = .time

        case .appearance:
            contentView.collectionType = .appearance
        }

        contentView.dragTitle = Localization.Wallpaper.Gallery.dragTitle
        contentView.dragSupplementaryTitle = Localization.Wallpaper.Gallery.dragSupplementary
        contentView.dragAlternativeTitle = Localization.Wallpaper.Gallery.or
        contentView.dragBrowseTitle = Localization.Wallpaper.Gallery.browse
        contentView.delegate = dragController

        contentView.galleryTextList = .init(
            azimuthText: Localization.Wallpaper.Gallery.azimuth,
            azimuthPlaceholder: Localization.Wallpaper.Gallery.azimuthValue,
            altitudeText: Localization.Wallpaper.Gallery.altitude,
            altitudePlaceholder: Localization.Wallpaper.Gallery.altitudeValue,
            timeText: Localization.Wallpaper.Gallery.time,
            lightAppearanceTooltipTitle:
                Localization.Wallpaper.Gallery.tooltipLightTitle,
            lightAppearanceTooltipDescription:
                Localization.Wallpaper.Gallery.tooltipLightDescription,
            darkAppearanceTooltipTitle:
                Localization.Wallpaper.Gallery.tooltipDarkTitle,
            darkAppearanceTooltipDescription:
                Localization.Wallpaper.Gallery.tooltipDarkDescription,
            previewTooltipTitle:
                Localization.Wallpaper.Gallery.tooltipPreviewTitle,
            previewTooltipDescription:
                Localization.Wallpaper.Gallery.tooltipPreviewDescription
        )
    }
    
    private func setupActions() {
        contentView.dragBrowseAction = { [weak self] _ in
            self?.delegate?.openBrowseDialog()
        }
    }

    // MARK: - Public
    
    var data: GalleryData {
        return dataController.data
    }

    var infoText: String {
        return dataController.data.info
    }

    func setOutputSizeText(_ text: String) {
        dataController.setOutputSizeText(text)
        contentView.reloadCollection(dataController.data, type: .soft)
    }

    func replace(with attributes: [ImageAttributes]) {
        let models = attributes.enumerated().map {
            order, attribute -> GalleryModel in
            let appearance: EquinoxUI.AppearanceType
            switch attribute.appearanceType {
            case .light: appearance = .light
            case .dark: appearance = .dark
            case .both: appearance = .both
            case nil: appearance = .all
            }
            var altitude: Double?
            var azimuth: Double?
            var time: Date?
            switch attribute.imageType {
            case .solar(let frameAltitude, let frameAzimuth):
                altitude = frameAltitude
                azimuth = frameAzimuth
            case .time(let date):
                time = date
            case .appearance:
                break
            }
            return GalleryModel(number: order + 1,
                                url: attribute.url,
                                appearance: appearance,
                                primary: attribute.primary,
                                azimuth: azimuth,
                                altitude: altitude,
                                time: time,
                                sourceIndex: attribute.sourceIndex)
        }
        dataController.replace(with: models)
        contentView.reloadCollection(dataController.data, type: .hard)
        refreshState()
        delegate?.dataWasChanged()
    }
    
    weak var delegate: WallpaperGalleryViewControllerDelegate?
    
    var isDragHighlighted: Bool {
        get {
            return contentView.isDragHighlighted
        }
        set {
            contentView.isDragHighlighted = newValue
        }
    }

    func didBrowse(_ urls: [URL]) {
        let insertIndexPath = IndexPath(item: dataController.data.items.count, section: 0)
        processExternalCollectionItems(urls, insertIndexPath: insertIndexPath)
    }
    
    func flashItems(_ indexPaths: Set<IndexPath>) {
        contentView.flashItems(at: indexPaths)
    }
    
    // MARK: - Private
    
    private func refreshData() {
        dataController.refreshData()
        contentView.reloadCollection(dataController.data, type: .soft)
        delegate?.dataWasChanged()
        refreshState()
    }
    
    private func refreshState() {
        let isEmpty = dataController.data.items.isEmpty
        
        contentView.setCollectionVisibility(!isEmpty, animated: true)
        contentView.isDragHidden = !isEmpty
        contentView.isDragHighlighted = false
        contentView.isSelectionEnabled = !isEmpty
    }
    
    @objc
    func collectionMenuDeleteItems(_ sender: Any) {
        deleteCollectionItems()
    }

    @objc
    func collectionMenuExportImage(_ sender: Any) {
        let files = contentView.selectedIndexPaths
            .sorted { $0.item < $1.item }
            .compactMap { filePromiseDetails(at: $0) }
        guard files.count == contentView.selectedIndexPaths.count,
              !files.isEmpty,
              let window = view.window else {
            return
        }

        guard files.count > 1 else {
            guard let file = files.first else { return }
            exportImage(file, in: window)
            return
        }

        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = FilePanelDirectories.save
        openPanel.beginSheetModal(for: window) { [weak self] result in
            guard result == .OK, let directoryURL = openPanel.url else {
                return
            }

            do {
                for file in files {
                    let data = try self?.exportData(
                        from: file.0,
                        sourceIndex: file.1
                    )
                    guard let data = data else { return }
                    let destinationURL = directoryURL.appendingPathComponent(
                        file.2
                    )
                    try data.write(to: destinationURL, options: .atomic)
                }
                FilePanelDirectories.rememberSave(for: directoryURL)
            } catch {
                self?.delegate?.notify(error.localizedDescription)
            }
        }
    }

    private func exportImage(
        _ file: (URL, Int?, String),
        in window: NSWindow
    ) {

        let savePanel = NSSavePanel()
        savePanel.directoryURL = FilePanelDirectories.save
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = file.2
        savePanel.canSelectHiddenExtension = true
        savePanel.isExtensionHidden = false
        let fileExtension = URL(fileURLWithPath: file.2).pathExtension
        savePanel.allowedContentTypes = [
            UTType(filenameExtension: fileExtension) ?? .data
        ]

        savePanel.beginSheetModal(for: window) { [weak self] result in
            guard result == .OK, let destinationURL = savePanel.url else {
                return
            }

            do {
                let exportData = try self?.exportData(
                    from: file.0,
                    sourceIndex: file.1
                )
                guard let exportData = exportData else { return }
                try exportData.write(to: destinationURL, options: .atomic)
                FilePanelDirectories.rememberSave(for: destinationURL)
            } catch {
                self?.delegate?.notify(error.localizedDescription)
            }
        }
    }

    private func exportData(from sourceURL: URL, sourceIndex: Int?) throws -> Data {
        let sourceData = try Data(contentsOf: sourceURL)
        guard let sourceIndex = sourceIndex else {
            return sourceData
        }
        return try ImageCoreImpl().extractHEICFrame(
            from: sourceData,
            at: sourceIndex
        )
    }
}

// MARK: - Drag and Drop

extension WallpaperGalleryViewController: WallpaperGalleryDragControllerDelegate {
    func filePromiseDetails(
        at indexPath: IndexPath
    ) -> (URL, Int?, String)? {
        guard dataController.data.items.indices.contains(indexPath.item) else {
            return nil
        }
        let model = dataController.data.items[indexPath.item]
        let sourceIndex = model.sourceIndex
        let name = model.url.deletingPathExtension().lastPathComponent
        let filename = sourceIndex.map { "\(name)-\($0 + 1).heic" }
            ?? model.url.lastPathComponent
        return (model.url, sourceIndex, filename)
    }

    func processInternalCollectionItems(
        _ indexPaths: [IndexPath], insertIndexPath: IndexPath
    ) {
        guard let items = GalleryDragOperations.moved(
            dataController.data.items,
            indices: indexPaths.map { $0.item },
            destination: insertIndexPath.item
        ) else { return }
        contentView.deselectCollectionItems(at: Set(indexPaths))
        dataController.replace(with: items)
        refreshData()
        contentView.reloadCollection(dataController.data, type: .hard)
    }

    func copyInternalCollectionItems(
        _ indexPaths: [IndexPath], insertIndexPath: IndexPath
    ) {
        let items = dataController.data.items
        let limit = type == .appearance
            ? max(0, Constants.maxAppearanceItemsCount - items.count)
            : nil
        let models = GalleryDragOperations.copies(
            items, indices: indexPaths.map { $0.item }, limit: limit
        )
        guard !models.isEmpty else { return }
        contentView.deselectCollectionItems(at: Set(indexPaths))
        dataController.insert(models, at: insertIndexPath.item)
        refreshData()
        contentView.reloadCollection(dataController.data, type: .hard)
    }

    func processExternalCollectionItems(_ urls: [URL], insertIndexPath: IndexPath) {
        var validatedUrls = imageProvider.validateImages(urls)
        
        if urls.count != validatedUrls.count {
            let wrongImagesCount = urls.count - validatedUrls.count
            delegate?.notify(Localization.Wallpaper.Gallery.wrongImagesType(param1: wrongImagesCount))
        }
        
        guard !validatedUrls.isEmpty else {
            return
        }
        
        switch type {
        case .solar, .time:
            break
            
        case .appearance:
            let distance = min(Constants.maxAppearanceItemsCount - dataController.data.items.count, validatedUrls.count)
            validatedUrls = Array(validatedUrls[0..<distance])
        }
        
        let items = dataController.make(validatedUrls, insertIndexPath: insertIndexPath)
        let models = items.map { $0.model }
        
        dataController.insert(models, at: insertIndexPath.item)
        refreshData()
        contentView.reloadCollection(dataController.data, type: .hard)
    }

    func deleteCollectionItems() {
        let indexPaths = contentView
            .selectedIndexPaths
            .sorted(by: >)
        
        guard !indexPaths.isEmpty else { return }
        contentView.deselectCollectionItems(at: Set(indexPaths))
        for indexPath in indexPaths {
            dataController.remove(at: indexPath.item)
        }
        refreshData()
        contentView.reloadCollection(dataController.data, type: .hard)
    }

    func canValidateCollectionDrag() -> Bool {
        switch type {
        case .solar, .time:
            return true

        case .appearance:
            return dataController.data.items.count < Constants.maxAppearanceItemsCount
        }
    }

    private func updateAppearance(
        _ selected: EquinoxUI.AppearanceType,
        for model: GalleryModel
    ) {
        let changed = GallerySelectionRules.setAppearance(
            selected, for: model, in: dataController.data.items
        )
        for item in changed {
            contentView.updateItem(
                at: item.number - 1, model: item, animated: true
            )
        }
        contentView.reloadCollection(dataController.data, type: .soft)
    }

    func refreshCollectionData(_ index: Int, field: GalleryModel.MutateField, sender: Any?) {
        guard dataController.data.items.indices.contains(index) else {
            return
        }

        let model = dataController.data.items[index]

        switch field {
        case .appearance(let selected):
            updateAppearance(selected, for: model)
            delegate?.dataWasChanged()

        case .primary:
            let changed = GallerySelectionRules.setPrimary(
                model, in: dataController.data.items
            )
            for item in changed {
                contentView.updateItem(
                    at: item.number - 1, model: item, animated: true
                )
            }
            contentView.reloadCollection(dataController.data, type: .soft)

        case .azimuth(let azimuth):
            model.azimuth = azimuth

        case .altitude(let altitude):
            model.altitude = altitude

        case .time(let time):
            model.time = time
        }
        if case .appearance = field { return }
        delegate?.dataWasChanged()
    }
    
    func loadImage(
        model: GalleryModel,
        completion: @escaping (NSImage?) -> Void
    ) {
        let resizeMode = ImageResizeMode.resized(size: Constants.thumbnailSize, respectAspect: true)
        imageProvider.loadImage(
            url: model.url,
            sourceIndex: model.sourceIndex,
            resizeMode: resizeMode,
            completion: completion
        )
    }

    func collectionMenuNeedsUpdate(_ menu: NSMenu) {
        let count = contentView.selectedIndexPaths.count
        
        menu.removeAllItems()
        if count > 1 {
            let selectionTitle = Localization.Wallpaper.Gallery
                .menuSelectedItems(param1: count)
            let selectionItem = NSMenuItem()
            let selectionView = SelectionCountMenuItemView(
                title: selectionTitle
            )
            selectionView.frame.size = selectionView.intrinsicContentSize
            selectionItem.view = selectionView
            menu.addItem(selectionItem)
            menu.addItem(.separator())
        }
        let exportableCount = contentView.selectedIndexPaths
            .filter { filePromiseDetails(at: $0) != nil }
            .count
        if count > 0, exportableCount == count {
            let exportItem = NSMenuItem(
                title: Localization.Wallpaper.Gallery.menuExport(
                    param1: count
                ),
                action: #selector(collectionMenuExportImage(_:)),
                keyEquivalent: String()
            )
            exportItem.target = self
            menu.addItem(exportItem)
        }
        let item = NSMenuItem(
            title: Localization.Wallpaper.Gallery.menuDelete(
                param1: count
            ),
            action: #selector(collectionMenuDeleteItems(_:)),
            keyEquivalent: String()
        )
        item.target = self
        menu.addItem(item)
    }
}
