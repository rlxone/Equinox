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

protocol WallpaperRootViewControllerDelegate: AnyObject {
    func rootViewControllerNewWasInteracted()
    func rootViewControllerCalculatorWasInteracted()
    func rootViewControllerShouldNotify(_ text: String)
    func rootViewControllerUnsavedChangesDidChange(_ hasChanges: Bool)
}

// MARK: - Class

final class WallpaperRootViewController: ViewController {
    private let type: WallpaperType
    private let fileService: FileService
    private let wallpaperService: WallpaperService
    private let solarService: SolarService
    private let settingsService: SettingsService
    private let imageProvider: ImageProvider
    private let initialAttributes: [ImageAttributes]?

    private lazy var contentView = RootContentView()
    private weak var navigationController: NavigationController?
    private weak var createViewController: WallpaperCreateViewController?
    private weak var mainViewController: WallpaperMainViewController?
    private weak var tipViewController: TipViewController?
    private weak var setViewController: WallpaperSetViewController?
    
    // MARK: - Initializer
    
    init(
        type: WallpaperType,
        fileService: FileService,
        wallpaperService: WallpaperService,
        solarService: SolarService,
        settingsService: SettingsService,
        imageProvider: ImageProvider,
        initialAttributes: [ImageAttributes]?
    ) {
        self.type = type
        self.fileService = fileService
        self.wallpaperService = wallpaperService
        self.solarService = solarService
        self.settingsService = settingsService
        self.imageProvider = imageProvider
        self.initialAttributes = initialAttributes
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
        presentMainController()
        if initialAttributes == nil {
            presentTipControllerIfNeeded(animated: false)
        }
    }
    
    // MARK: - Public

    weak var delegate: WallpaperRootViewControllerDelegate?

    var canRevert: Bool {
        return initialAttributes != nil
            && createViewController == nil
            && mainViewController?.canRevert == true
    }

    var hasUnsavedChanges: Bool {
        return mainViewController?.hasUnsavedChanges == true
    }

    func revert() {
        guard canRevert else { return }
        mainViewController?.revert()
    }
    
    public func presentTipController(firstPresent: Bool, animated: Bool) {
        guard tipViewController == nil else {
            return
        }
        
        var title: String
        var description: String
        var image: NSImage
        
        let status = Localization.Tip.Shared.tips
        let buttonTitle = firstPresent ? Localization.Tip.Shared.started : Localization.Tip.Shared.ok
        
        switch type {
        case .solar:
            title = Localization.Tip.Solar.title
            description = Localization.Tip.Solar.description
            image = Image.solarTip
            
        case .time:
            title = Localization.Tip.Time.title
            description = Localization.Tip.Time.description
            image = Image.timeTip
            
        case .appearance:
            title = Localization.Tip.Appearance.title
            description = Localization.Tip.Appearance.description
            image = Image.appearanceTip
        }
        
        let controller = TipViewController(
            model: .init(
                title: title,
                description: description,
                status: status,
                buttonTitle: buttonTitle,
                image: image
            )
        )
        controller.delegate = self
        tipViewController = controller
        
        self.navigationController?.present(controller, animated: animated)
    }
    
    // MARK: - Private

    private func presentMainController() {
        let controller = WallpaperMainViewController(
            type: type,
            fileService: fileService,
            wallpaperService: wallpaperService,
            solarService: solarService,
            imageProvider: imageProvider,
            initialAttributes: initialAttributes
        )
        mainViewController = controller
        controller.delegate = self
        let navigationController = NavigationController(rootViewController: controller)
        self.navigationController = navigationController
        addChildController(navigationController, container: view)
    }
    
    private func presentTipControllerIfNeeded(animated: Bool) {
        let hasWalkthrough: Bool
        
        switch type {
        case .solar:
            hasWalkthrough = settingsService.hasWalkthrough(type: .solarWallpaper)
            
        case .time:
            hasWalkthrough = settingsService.hasWalkthrough(type: .timeWallpaper)
            
        case .appearance:
            hasWalkthrough = settingsService.hasWalkthrough(type: .appearanceWallpaper)
        }
        
        if !hasWalkthrough {
            presentTipController(firstPresent: true, animated: animated)
        }
    }
    
    private func presentSetController() {
        let controller = WallpaperSetViewController()
        controller.delegate = self
        setViewController = controller
        self.navigationController?.present(controller, animated: true)
    }

    private func presentCreateController(
        _ imageAttributes: [ImageAttributes],
        settings: ImageExportSettings,
        previewURL: URL? = nil
    ) {
        guard createViewController == nil else {
            return
        }
        let controller = WallpaperCreateViewController(
            type: type,
            imageAttributes: imageAttributes,
            wallpaperService: wallpaperService,
            imageProvider: imageProvider,
            exportSettings: settings,
            sourceURL: initialAttributes?.first?.url,
            previewURL: previewURL
        )
        createViewController = controller
        controller.delegate = self
        navigationController?.present(controller)
    }
}

// MARK: - MainViewControllerDelegate

extension WallpaperRootViewController: WallpaperMainViewControllerDelegate {
    func mainViewControllerUnsavedChangesDidChange(_ hasChanges: Bool) {
        delegate?.rootViewControllerUnsavedChangesDidChange(hasChanges)
    }

    func mainViewControllerCalculatorWasInteracted() {
        delegate?.rootViewControllerCalculatorWasInteracted()
    }

    func mainViewControllerCreateWasInteracted(
        _ imageAttributes: [ImageAttributes],
        settings: ImageExportSettings,
        previewURL: URL?
    ) {
        presentCreateController(
            imageAttributes,
            settings: settings,
            previewURL: previewURL
        )
    }

    func mainViewControllerBackWasInteracted() {
        navigationController?.popBack()
    }
    
    func mainViewControllerShouldNotify(_ text: String) {
        delegate?.rootViewControllerShouldNotify(text)
    }
}

// MARK: - CreateViewControllerDelegate

extension WallpaperRootViewController: WallpaperCreateViewControllerDelegate {
    func createViewControllerDismissWasInteracted() {
        guard let controller = createViewController else {
            return
        }
        navigationController?.dismiss(controller, animated: true)
    }

    func createViewControllerNewWasInteracted() {
        delegate?.rootViewControllerNewWasInteracted()
    }
    
    func createViewControllerSetWasInteracted() {
        let hasWalkthrough = settingsService.hasWalkthrough(type: .setWallpaper)
        if hasWalkthrough {
            createViewController?.continueSaveImage()
        } else {
            presentSetController()
        }
    }

    func createViewControllerRepeatWasInteracted() {
        guard let controller = createViewController else {
            return
        }
        navigationController?.dismiss(controller, animated: false)
        presentMainController()
    }

    func createViewControllerShouldNotify(_ text: String) {
        delegate?.rootViewControllerShouldNotify(text)
    }

    func createViewControllerDidSave() {
        mainViewController?.markSaved()
    }
}

// MARK: - TipViewControllerDelegate

extension WallpaperRootViewController: TipViewControllerDelegate {
    func getStartedWasInteracted() {
        guard let tipViewController = tipViewController else {
            return
        }
        
        switch type {
        case .solar:
            settingsService.setWalkthrough(type: .solarWallpaper)
            
        case .time:
            settingsService.setWalkthrough(type: .timeWallpaper)
            
        case .appearance:
            settingsService.setWalkthrough(type: .appearanceWallpaper)
        }
        
        navigationController?.dismiss(tipViewController, animated: true)
    }
}

// MARK: - WallpaperSetViewControllerDelegate

extension WallpaperRootViewController: WallpaperSetViewControllerDelegate {
    func setViewControllerContinueWasInteracted(skip: Bool) {
        guard let controller = setViewController else {
            return
        }
        createViewController?.continueSaveImage()
        if skip {
            settingsService.setWalkthrough(type: .setWallpaper)
        }
        navigationController?.dismiss(controller, animated: true)
    }
}
