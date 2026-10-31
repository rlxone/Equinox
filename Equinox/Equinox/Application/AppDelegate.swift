// Copyright (c) 2018 Dmitry Meduho
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

enum FilePanelDirectories {
    private static let openKey = "openPanelLastDirectory"
    private static let saveKey = "savePanelLastDirectory"

    static var open: URL? {
        return directory(forKey: openKey)
    }

    static var save: URL? {
        return directory(forKey: saveKey)
    }

    static func rememberOpen(for fileURL: URL) {
        remember(fileURL, forKey: openKey)
    }

    static func rememberSave(for fileURL: URL) {
        remember(fileURL, forKey: saveKey)
    }

    private static func directory(forKey key: String) -> URL? {
        guard let path = UserDefaults.standard.string(forKey: key) else {
            return nil
        }

        return URL(fileURLWithPath: path, isDirectory: true)
    }

    private static func remember(_ fileURL: URL, forKey key: String) {
        UserDefaults.standard.set(
            fileURL.deletingLastPathComponent().path,
            forKey: key
        )
    }
}

final class AppDelegate: NSObject {
    let storiesController: StoriesController = StoriesControllerImpl()
}

// MARK: - NSApplicationDelegate

extension AppDelegate: NSApplicationDelegate {
    func applicationShouldTerminate(
        _ sender: NSApplication
    ) -> NSApplication.TerminateReply {
        return storiesController.shouldTerminate()
            ? .terminateNow
            : .terminateCancel
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenu()
        storiesController.start()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let dock = DockMenu(title: NSApplication.appName)
        dock.dockDelegate = self
        return dock
    }

    func application(
        _ sender: NSApplication,
        openFile filename: String
    ) -> Bool {
        return openWallpaper(URL(fileURLWithPath: filename))
    }
    
    // MARK: - Private
    
    private func setupMenu() {
        let applicationMenu = ApplicationMenu(title: NSApplication.appName)
        applicationMenu.applicationDelegate = self
        NSApplication.shared.mainMenu = applicationMenu
    }

    private func openWallpaper(_ url: URL) -> Bool {
        do {
            try storiesController.open(url)
            return true
        } catch {
            let alert = NSAlert()
            alert.messageText = Localization.Menu.File.openErrorTitle
            alert.informativeText = error is MetadataError
                ? Localization.Menu.File.openErrorDescription
                : error.localizedDescription
            alert.alertStyle = .warning
            alert.runModal()
            return false
        }
    }
}

// MARK: - ApplicationMenuDelegate

extension AppDelegate: ApplicationMenuDelegate {
    @objc
    func applicationMenuNew(_ sender: Any?) {
        storiesController.new()
    }

    func applicationMenuOpen(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.directoryURL = FilePanelDirectories.open
        panel.title = Localization.Menu.File.open
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        if #available(macOS 11.0, *) {
            panel.allowedContentTypes = [.heic, .heif]
        }
        panel.begin { [weak self] result in
            guard result == .OK, let url = panel.url else { return }
            FilePanelDirectories.rememberOpen(for: url)
            _ = self?.openWallpaper(url)
        }
    }

    func applicationMenuRevert(_ sender: Any?) {
        let controller = NSApp.keyWindow?.windowController
            as? WallpaperWindowController
        controller?.revert()
    }

    func applicationMenuCanRevert() -> Bool {
        let controller = NSApp.keyWindow?.windowController
            as? WallpaperWindowController
        return controller?.canRevert == true
    }
}

// MARK: - DockMenuDelegate

extension AppDelegate: DockMenuDelegate {
    func dockMenuNew(_ sender: Any?) {
        storiesController.new()
    }
}
