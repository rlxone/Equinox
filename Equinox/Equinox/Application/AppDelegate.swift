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

final class AppDelegate: NSObject {
    let storiesController: StoriesController = StoriesControllerImpl()
}

// MARK: - NSApplicationDelegate

extension AppDelegate: NSApplicationDelegate {
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
    
    // MARK: - Private
    
    private func setupMenu() {
        let applicationMenu = ApplicationMenu(title: NSApplication.appName)
        applicationMenu.applicationDelegate = self
        NSApplication.shared.mainMenu = applicationMenu
    }
}

// MARK: - ApplicationMenuDelegate

extension AppDelegate: ApplicationMenuDelegate {
    func applicationMenuNew(_ sender: Any?) {
        storiesController.new()
    }
}

// MARK: - DockMenuDelegate

extension AppDelegate: DockMenuDelegate {
    func dockMenuNew(_ sender: Any?) {
        storiesController.new()
    }
}
