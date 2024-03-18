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
import EquinoxCore
import EquinoxUI

// MARK: - Protocols

@objc
protocol StoriesController {
    func start()
    func new()
}

// MARK: - Enums, Structs

extension StoriesControllerImpl {
    private enum Constants {
        static let imageCacheLimit = 512 * 1_024 * 1_024
    }
}

// MARK: - Class

final class StoriesControllerImpl: NSObject {
    private var welcomeWindowController: WelcomeWindowController?
    private var wallpaperWindowControllers = [WallpaperWindowController]()
    private var solarWindowController: SolarWindowController?
}

// MARK: - StoriesController

extension StoriesControllerImpl: StoriesController {
    func start() {
        presentWelcome()
    }
    
    func new() {
        presentWelcome()
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
    
    private func presentWallpaper(selectedType: WallpaperType) {
        let imageCore = ImageCoreImpl()
        let imageCacheCore = ImageCacheCoreImpl(totalCostLimit: Constants.imageCacheLimit)
        let fileCore = FileCoreImpl()
        let metadataCore = MetadataCoreImpl()
        let solarCore = SolarCoreImpl()
        let storageCore = StorageCoreImpl(userDefaults: .standard)
        
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
            )
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
                settingsService: SettingsServiceImpl(storageCore: StorageCoreImpl(userDefaults: .standard))
            )
            controller.window?.delegate = self
            solarWindowController = controller
        }
    }
}

// MARK: - NSWindowDelegate

extension StoriesControllerImpl: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        let closeWindow = sender
        if let index = wallpaperWindowControllers.firstIndex(where: { $0.window === closeWindow }) {
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
        
        return true
    }
}

// MARK: - WelcomeWindowControllerDelegate

extension StoriesControllerImpl: WelcomeWindowControllerDelegate {
    func welcomeWindowControllerTypeWasSelected(type: WallpaperType) {
        welcomeWindowController?.close()
        welcomeWindowController = nil
        presentWallpaper(selectedType: type)
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
