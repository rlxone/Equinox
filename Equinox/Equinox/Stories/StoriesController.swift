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

@objc
protocol StoriesController {
    func start()
    func new()
    func open(_ url: URL) throws
    func shouldTerminate() -> Bool
}

// MARK: - Enums, Structs

extension StoriesControllerImpl {
    private enum Constants {
        static let imageCacheLimit = 512 * 1_024 * 1_024
    }
}

// MARK: - Class

final class StoriesControllerImpl: NSObject {
    private lazy var storageCore: StorageCore = StorageCoreImpl(userDefaults: .standard)
    private lazy var supportService: SupportService = SupportServiceImpl(storageCore: storageCore)

    private var welcomeWindowController: WelcomeWindowController?
    private var supportWindowController: SupportWindowController?
    private var wallpaperWindowControllers = [WallpaperWindowController]()
    private var solarWindowController: SolarWindowController?
}

// MARK: - StoriesController

extension StoriesControllerImpl: StoriesController {
    func shouldTerminate() -> Bool {
        guard wallpaperWindowControllers.contains(where: {
            $0.hasUnsavedChanges
        }) else {
            return true
        }
        return confirmDiscardingChanges(
            description: Localization.UnsavedChanges.quitDescription
        )
    }

    func start() {
        presentWelcome()
    }
    
    func new() {
        presentWelcome()
    }

    func open(_ url: URL) throws {
        let opened = try MetadataCoreImpl().readWallpaper(at: url)
        let type: WallpaperType
        switch opened.type {
        case .solar: type = .solar
        case .time: type = .time
        case .appearance: type = .appearance
        }
        welcomeWindowController?.close()
        welcomeWindowController = nil
        presentWallpaper(selectedType: type,
                         sourceURL: url,
                         initialAttributes: opened.attributes)
    }
    
    private func presentWelcome() {
        if let welcomeWindowController = welcomeWindowController {
            welcomeWindowController.window?.makeKeyAndOrderFront(self)
        } else {
            let welcomeWindowController = WelcomeWindowController()
            welcomeWindowController.delegate = self
            welcomeWindowController.window?.delegate = self
            self.welcomeWindowController = welcomeWindowController
        }
    }
    
    private func presentWallpaper(
        selectedType: WallpaperType,
        sourceURL: URL? = nil,
        initialAttributes: [ImageAttributes]? = nil
    ) {
        let imageCore = ImageCoreImpl()
        let imageCacheCore = ImageCacheCoreImpl(totalCostLimit: Constants.imageCacheLimit)
        let fileCore = FileCoreImpl()
        let metadataCore = MetadataCoreImpl()
        let solarCore = SolarCoreImpl()
        
        let windowController = WallpaperWindowController(
            type: selectedType,
            fileService: FileServiceImpl(
                imageCore: imageCore,
                fileCore: fileCore
            ),
            wallpaperService: WallpaperServiceImpl(
                metadataCore: metadataCore,
                imageCore: imageCore
            ),
            solarService: SolarServiceImpl(solarCore: solarCore),
            settingsService: SettingsServiceImpl(storageCore: storageCore),
            imageProvider: ImageProviderImpl(
                imageService: ImageServiceImpl(
                    metadataCore: metadataCore,
                    imageCore: imageCore,
                    imageCacheCore: imageCacheCore
                )
            ),
            sourceURL: sourceURL,
            initialAttributes: initialAttributes
        )
        windowController.delegate = self
        windowController.window?.delegate = self
        wallpaperWindowControllers.append(windowController)
    }

    private func presentSolar() {
        if let solarWindowController = solarWindowController {
            solarWindowController.window?.makeKeyAndOrderFront(self)
        } else {
            let controller = SolarWindowController(
                solarService: SolarServiceImpl(solarCore: SolarCoreImpl()),
                settingsService: SettingsServiceImpl(storageCore: storageCore)
            )
            controller.window?.delegate = self
            solarWindowController = controller
        }
    }
    
    private func presentSupport() {
        if let supportWindowController = supportWindowController {
            supportWindowController.window?.makeKeyAndOrderFront(self)
        } else {
            let controller = SupportWindowController(supportService: supportService)
            controller.delegate = self
            controller.window?.delegate = self
            supportWindowController = controller
        }
    }
}

// MARK: - NSWindowDelegate

extension StoriesControllerImpl: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        let closeWindow = sender
        if let index = wallpaperWindowControllers.firstIndex(where: { $0.window === closeWindow }) {
            guard !wallpaperWindowControllers[index].hasUnsavedChanges
                || confirmDiscardingChanges(
                    description: Localization.UnsavedChanges.closeDescription
                ) else {
                return false
            }
            wallpaperWindowControllers.remove(at: index)
            if wallpaperWindowControllers.isEmpty {
                NSApp.terminate(self)
            }
        }
        if closeWindow == solarWindowController?.window {
            solarWindowController = nil
        }
        if closeWindow == welcomeWindowController?.window {
            welcomeWindowController = nil
        }
        if closeWindow == supportWindowController?.window {
            supportWindowController = nil
        }
        return true
    }

    private func confirmDiscardingChanges(description: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = Localization.UnsavedChanges.title
        alert.informativeText = description
        alert.alertStyle = .warning
        alert.addButton(withTitle: Localization.UnsavedChanges.discard)
        alert.addButton(withTitle: Localization.Wallpaper.Create.cancel)
        return alert.runModal() == .alertFirstButtonReturn
    }
}

// MARK: - WelcomeWindowControllerDelegate

extension StoriesControllerImpl: WelcomeWindowControllerDelegate {
    func welcomeWindowControllerTypeWasSelected(type: WallpaperType) {
        welcomeWindowController?.close()
        welcomeWindowController = nil
        presentWallpaper(selectedType: type)
    }

    func welcomeWindowControllerOpenWasInteracted() {
        (NSApp.delegate as? AppDelegate)?.applicationMenuOpen(nil)
    }
    
    func welcomeWindowControllerSupportWasInteracted() {
        presentSupport()
    }
}

// MARK: - WallpaperWindowControllerDelegate

extension StoriesControllerImpl: WallpaperWindowControllerDelegate {
    func wallpaperWindowControllerNewWasInteracted() {
        start()
    }
    
    func wallpaperWindowControllerCalculatorWasInteracted() {
        presentSolar()
    }
}

// MARK: - SupportWindowControllerDelegate

extension StoriesControllerImpl: SupportWindowControllerDelegate {
    func supportWindowDidClose() {
        supportWindowController?.close()
        supportWindowController = nil
    }
}
