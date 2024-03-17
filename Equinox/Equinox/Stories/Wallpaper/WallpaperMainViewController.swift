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

protocol WallpaperMainViewControllerDelegate: AnyObject {
    func mainViewControllerCreateWasInteracted(_ imageAttributes: [ImageAttributes])
    func mainViewControllerCalculatorWasInteracted()
    func mainViewControllerBackWasInteracted()
    func mainViewControllerHelpWasInteracted()
    func mainViewControllerShouldNotify(_ text: String)
}

// MARK: - Enums, Structs

extension WallpaperMainViewController {
    private enum Constants {
        static let appearancePopoverSize = NSSize(width: 260, height: 161)
        static let minimumItemsCount = 1
        static let minimumAppearanceItemsCount = 2
    }
}

// MARK: - Class

final class WallpaperMainViewController: ViewController {
    private let type: WallpaperType
    private let fileService: FileService
    private let solarService: SolarService
    private let imageProvider: ImageProvider
    
    private weak var appearancePopover: NSPopover?
    private weak var appearancePopoverView: NSView?
    private weak var galleryController: WallpaperGalleryViewController?

    lazy var contentView: MainContentView = {
        let view = MainContentView()
        view.style = .default
        return view
    }()

    // MARK: - Initializer

    init(
        type: WallpaperType,
        fileService: FileService,
        solarService: SolarService,
        imageProvider: ImageProvider
    ) {
        self.type = type
        self.fileService = fileService
        self.solarService = solarService
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
        addGalleryController()
        
        switch type {
        case .solar:
            contentView.toolBarTitle = Localization.Wallpaper.Main.solar
            contentView.menuItems = [
                .button(title: Localization.Wallpaper.Main.calculator) { [weak self] _ in
                    self?.delegate?.mainViewControllerCalculatorWasInteracted()
                }
            ]

        case .time:
            contentView.toolBarTitle = Localization.Wallpaper.Main.time

        case .appearance:
            contentView.toolBarTitle = Localization.Wallpaper.Main.appearance
        }

        contentView.createButtonTitle = Localization.Wallpaper.Main.create
        contentView.isCreateButtonEnabled = false
    }

    private func setupActions() {
        contentView.createButtonAction = { [weak self] _ in
            guard let self = self else {
                return
            }
            let result = self.validateData()
            if let result = result {
                self.galleryController?.flashItems(result)
                self.delegate?.mainViewControllerShouldNotify(Localization.Wallpaper.Main.validate)
            } else {
                guard let imageAttributes = self.convertData() else {
                    return
                }
                self.delegate?.mainViewControllerCreateWasInteracted(imageAttributes)
            }
        }

        contentView.toolBarBackButtonAction = { [weak self] _ in
            self?.delegate?.mainViewControllerBackWasInteracted()
        }
        
        contentView.helpAction = { [weak self] in
            self?.delegate?.mainViewControllerHelpWasInteracted()
        }
    }

    // MARK: - Public

    weak var delegate: WallpaperMainViewControllerDelegate?

    // MARK: - Private

    private func convertData() -> [ImageAttributes]? {
        var imageAttributes = [ImageAttributes]()

        guard let data = galleryController?.data else {
            return nil
        }

        for model in data.items {
            let imageType: ImageType
            let appearanceType: EquinoxCore.AppearanceType?

            switch type {
            case .solar:
                imageType = .solar(altitude: model.altitude ?? 0, azimuth: model.azimuth ?? 0)

            case .time:
                imageType = .time(date: model.time ?? Date())

            case .appearance:
                imageType = .appearance
            }

            switch model.appearance {
            case .all:
                appearanceType = nil

            case .light:
                appearanceType = .light

            case .dark:
                appearanceType = .dark
            }

            imageAttributes.append(ImageAttributes(
                url: model.url,
                index: model.number - 1,
                primary: model.primary,
                imageType: imageType,
                appearanceType: appearanceType
            ))
        }

        return imageAttributes
    }
    
    private func validateData() -> Set<IndexPath>? {
        guard let data = galleryController?.data else {
            return nil
        }
        
        switch type {
        case .solar:
            var errorIndexPaths = Set<IndexPath>()
            for item in data.items where item.altitude == nil || item.azimuth == nil {
                errorIndexPaths.insert(IndexPath(item: item.number - 1, section: 0))
            }
            return errorIndexPaths.isEmpty ? nil : errorIndexPaths
            
        case .time, .appearance:
            return nil
        }
    }
    
    private func addGalleryController() {
        let controller = WallpaperGalleryViewController(
            type: type,
            solarService: solarService,
            fileService: fileService,
            imageProvider: imageProvider
        )
        galleryController = controller
        controller.delegate = self
        addChildController(controller, container: contentView.containerView)
    }
    
    private var canCreateWallpaper: Bool {
        guard let count = galleryController?.data.items.count else {
            return false
        }

        var minItemsCount: Int

        switch type {
        case .solar, .time:
            minItemsCount = Constants.minimumItemsCount

        case .appearance:
            minItemsCount = Constants.minimumAppearanceItemsCount
        }
        
        return count >= minItemsCount
    }
}

// MARK: - GalleryViewControllerDelegate

extension WallpaperMainViewController: WallpaperGalleryViewControllerDelegate {
    func openBrowseDialog() {
        guard let window = view.window else {
            return
        }
        
        let openPanel = NSOpenPanel()
        openPanel.title = Localization.Wallpaper.Main.browse
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = true
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        if #available(macOS 11.0, *) {
            openPanel.allowedContentTypes = ImageFormatType.allCases.utTypes
        }
        
        openPanel.beginSheetModal(for: window) { [weak self] result in
            guard let self = self, result == .OK else {
                return
            }
            self.galleryController?.didBrowse(openPanel.urls)
        }
    }
    
    func presentAppearancePopover(relativeTo view: NSView, selectedType: EquinoxUI.AppearanceType) {
        guard appearancePopover == nil || view != appearancePopoverView else {
            return
        }

        let controller = WallpaperAppearanceViewController(type: type)
        controller.delegate = self

        switch selectedType {
        case .all:
            controller.selectedAppearanceType = .all

        case .light:
            controller.selectedAppearanceType = .light

        case .dark:
            controller.selectedAppearanceType = .dark
        }

        let popover = NSPopover()
        popover.contentSize = Constants.appearancePopoverSize
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = controller
        popover.show(relativeTo: .zero, of: view, preferredEdge: .minY)

        appearancePopover = popover
        appearancePopoverView = view
    }
    
    func closePopover() {
        appearancePopover?.close()
        appearancePopoverView = nil
    }
    
    func dataWasChanged() {
        contentView.isCreateButtonEnabled = canCreateWallpaper
    }
    
    func notify(_ text: String) {
        delegate?.mainViewControllerShouldNotify(text)
    }
}

// MARK: - AppearanceViewControllerDelegate

extension WallpaperMainViewController: WallpaperAppearanceViewControllerDelegate {
    func didSelect(_ model: AppearanceContentView.Model) {
        closePopover()
        galleryController?.didSelectAppearance(model)
    }
}
