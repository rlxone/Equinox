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

protocol WallpaperWindowControllerDelegate: AnyObject {
    func wallpaperWindowControllerNewWasInteracted()
    func wallpaperWindowControllerCalculatorWasInteracted()
}

// MARK: - Enums, Structs

extension WallpaperWindowController {
    private enum Constants {
        static let regularSize = NSSize(width: 930, height: 756)
        static let minSize = NSSize(width: 800, height: 650)
    }
}

// MARK: - Class

final class WallpaperWindowController: WindowController {
    private let type: WallpaperType
    private let fileService: FileService
    private let wallpaperService: WallpaperService
    private let solarService: SolarService
    private let settingsService: SettingsService
    private let imageProvider: ImageProvider

    private var contentWindow: Window?
    private var contentController: WindowViewController?

    init(
        type: WallpaperType,
        fileService: FileService,
        wallpaperService: WallpaperService,
        solarService: SolarService,
        settingsService: SettingsService,
        imageProvider: ImageProvider
    ) {
        self.type = type
        self.fileService = fileService
        self.wallpaperService = wallpaperService
        self.solarService = solarService
        self.settingsService = settingsService
        self.imageProvider = imageProvider
        super.init(window: nil)
        setupWindow()
    }
    
    // MARK: - Setup
    
    private func setupWindow() {
        let title = NSApplication.appName
        let controller = WallpaperRootViewController(
            type: type,
            fileService: fileService,
            wallpaperService: wallpaperService,
            solarService: solarService,
            settingsService: settingsService,
            imageProvider: imageProvider
        )
        controller.delegate = self

        let windowController = WindowViewController(contentViewController: controller, windowTitle: title)
        contentController = windowController

        contentWindow = Window(
            contentViewController: windowController,
            minSize: Constants.minSize
        )

        window = contentWindow
        window?.setContentSize(Constants.regularSize)
        setWindowTitle(appName: title)
        window?.makeKeyAndOrderFront(self)
        window?.center()
    }
    
    private func setWindowTitle(appName: String) {
        var title: String
        
        switch type {
        case .solar:
            title = "\(appName) - \(Localization.Wallpaper.Main.solar)"
            
        case .time:
            title = "\(appName) - \(Localization.Wallpaper.Main.time)"
            
        case .appearance:
            title = "\(appName) - \(Localization.Wallpaper.Main.appearance)"
        }
        
        window?.title = title
        window?.miniwindowTitle = title
    }
    
    // MARK: - Public
    
    weak var delegate: WallpaperWindowControllerDelegate?
}

// MARK: - WallpaperRootViewControllerDelegate

extension WallpaperWindowController: WallpaperRootViewControllerDelegate {
    func rootViewControllerNewWasInteracted() {
        delegate?.wallpaperWindowControllerNewWasInteracted()
    }
    
    func rootViewControllerCalculatorWasInteracted() {
        delegate?.wallpaperWindowControllerCalculatorWasInteracted()
    }

    func rootViewControllerShouldNotify(_ text: String) {
        contentController?.notify(text)
    }
}
