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

// MARK: - Protocols

protocol WallpaperGalleryViewControllerDelegate: AnyObject {
    func dataWasChanged()
    func openBrowseDialog()
    func presentAppearancePopover(relativeTo view: NSView, selectedType: EquinoxUI.AppearanceType)
    func closePopover()
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
        fileService: fileService,
        solarService: solarService,
        imageProvider: imageProvider
    )
    private weak var mutatingModel: GalleryModel?
    
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
            appearanceTooltipTitle: Localization.Wallpaper.Gallery.tooltipAppearanceTitle,
            appearanceTooltipDescription: Localization.Wallpaper.Gallery.tooltipAppearanceDescription,
            primaryTooltipTitle: Localization.Wallpaper.Gallery.tooltipPrimaryTitle,
            primaryTooltipDescription: Localization.Wallpaper.Gallery.tooltipPrimaryDescription
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
    
    weak var delegate: WallpaperGalleryViewControllerDelegate?
    
    var isDragHighlighted: Bool {
        get {
            return contentView.isDragHighlighted
        }
        set {
            contentView.isDragHighlighted = newValue
        }
    }

    func didSelectAppearance(_ model: AppearanceContentView.Model) {
        if let findedModel = dataController.data.items.first(where: { $0.appearance == model.appearanceType }),
           mutatingModel?.number != findedModel.number {
            let appearanceType: EquinoxUI.AppearanceType

            switch type {
            case .solar, .time:
                appearanceType = .all

            case .appearance:
                switch model.appearanceType {
                case .light:
                    appearanceType = .dark

                case .all, .dark:
                    appearanceType = .light
                }
            }
            
            findedModel.appearance = appearanceType
            contentView.updateItem(at: findedModel.number - 1, model: findedModel, animated: true)
        }

        if let mutatingModel = mutatingModel {
            switch model.appearanceType {
            case .all:
                mutatingModel.appearance = .all

            case .dark:
                mutatingModel.appearance = .dark

            case .light:
                mutatingModel.appearance = .light
            }

            contentView.updateItem(at: mutatingModel.number - 1, model: mutatingModel, animated: true)
        }
        
        contentView.reloadCollection(dataController.data, type: .soft)
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
}

// MARK: - Drag and Drop

extension WallpaperGalleryViewController: WallpaperGalleryDragControllerDelegate {
    func processInternalCollectionItems(_ indexPaths: [IndexPath], insertIndexPath: IndexPath) {
        var moveIndexPaths: [IndexPath] = []
        var shift = 0
        var values: [GalleryModel] = []

        for (index, indexPath) in indexPaths.enumerated() {
            if indexPath.item < insertIndexPath.item {
                shift += 1
            }
            let shiftedIndex = indexPath.item - index
            let model = dataController.data.items[shiftedIndex]
            values.append(model)
            dataController.remove(at: shiftedIndex)
            moveIndexPaths.append(indexPath)
        }

        let insertIndex = insertIndexPath.item - shift
        dataController.insert(values, at: insertIndex)
        refreshData()

        contentView.performCollectionUpdates({ [weak self] in
            for (index, indexPath) in moveIndexPaths.enumerated() {
                let destinationIndexPath = IndexPath(item: insertIndex + index, section: indexPath.section)
                self?.contentView.moveCollectionItem(at: indexPath, to: destinationIndexPath)
            }
            self?.contentView.deselectCollectionItems(at: Set(moveIndexPaths))
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.contentView.reloadCollection(self.dataController.data, type: .hard)
        })
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
        let indexPaths = items.map { $0.indexPath }
        
        dataController.insert(models, at: insertIndexPath.item)
        refreshData()
        
        contentView.performCollectionUpdates({ [weak self] in
            let indexPathsSet = Set(indexPaths)
            self?.contentView.insertCollectionItems(at: indexPathsSet)
            self?.contentView.deselectCollectionItems(at: indexPathsSet)
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.contentView.reloadCollection(self.dataController.data, type: .hard)
        })
    }

    func deleteCollectionItems() {
        let indexPaths = contentView
            .selectedIndexPaths
            .sorted(by: >)
        
        for indexPath in indexPaths {
            dataController.remove(at: indexPath.item)
        }
        
        refreshData()
        
        contentView.performCollectionUpdates({ [weak self] in
            let indexPathsSet = Set(indexPaths)
            self?.contentView.deleteCollectionItems(at: indexPathsSet)
            self?.contentView.deselectCollectionItems(at: indexPathsSet)
        }, completion: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.contentView.reloadCollection(self.dataController.data, type: .hard)
        })
    }
    
    func canValidateCollectionDrag() -> Bool {
        switch type {
        case .solar, .time:
            return true

        case .appearance:
            return dataController.data.items.count < Constants.maxAppearanceItemsCount
        }
    }

    func refreshCollectionData(_ index: Int, field: GalleryModel.MutateField, sender: Any?) {
        let model = dataController.data.items[index]

        switch field {
        case .appearance:
            guard let sender = sender as? NSView else {
                return
            }
            mutatingModel = model
            delegate?.presentAppearancePopover(relativeTo: sender, selectedType: model.appearance)

        case .primary:
            if let primaryIndex = dataController.data.items.firstIndex(where: { $0.primary }) {
                let primaryModel = dataController.data.items[primaryIndex]
                primaryModel.primary = false
                contentView.updateItem(at: primaryIndex, model: primaryModel, animated: true)
            }
            model.primary = true
            contentView.updateItem(at: index, model: model, animated: true)
            contentView.reloadCollection(dataController.data, type: .soft)

        case .azimuth(let azimuth):
            model.azimuth = azimuth

        case .altitude(let altitude):
            model.altitude = altitude

        case .time(let time):
            model.time = time
        }
    }
    
    func loadImage(url: URL, completion: @escaping (NSImage?) -> Void) {
        let resizeMode = ImageResizeMode.resized(size: Constants.thumbnailSize, respectAspect: true)
        imageProvider.loadImage(url: url, resizeMode: resizeMode, completion: completion)
    }

    func collectionDidScroll() {
        delegate?.closePopover()
    }
    
    func collectionMenuNeedsUpdate(_ menu: NSMenu) {
        let count = contentView.selectedIndexPaths.count
        
        menu.removeAllItems()
        let item = NSMenuItem(
            title: Localization.Wallpaper.Gallery.menuDelete(param1: count),
            action: #selector(collectionMenuDeleteItems(_:)),
            keyEquivalent: String()
        )
        item.target = self
        menu.addItem(item)
    }
}
