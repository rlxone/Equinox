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

// MARK: - Protocols

protocol DockMenuDelegate: AnyObject {
    func dockMenuNew(_ sender: Any?)
}

// MARK: - Class

final class DockMenu: NSMenu {
    override init(title: String) {
        super.init(title: title)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        for window in NSApp.windows {
            let windowMenuItem = getWindowMenuItem(title: window.miniwindowTitle)
            windowMenuItem.holdingObject = window
            if NSApp.mainWindow == window {
                windowMenuItem.state = .on
            }
            addItem(windowMenuItem)
        }
        
        if !NSApp.windows.isEmpty {
            addItem(.separator())
        }
        
        addItem(newMenuItem)
    }
    
    // MARK: - Public
    
    weak var dockDelegate: DockMenuDelegate?
    
    // MARK: - Private
    
    @objc
    private func new(_ sender: Any?) {
        dockDelegate?.dockMenuNew(sender)
    }
    
    @objc
    private func openWindow(_ sender: Any?) {
        guard
            let menuItem = sender as? MenuItem,
            let window = menuItem.holdingObject as? NSWindow
        else {
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(self)
    }
    
    private var newMenuItem: MenuItem {
        let menuItem = MenuItem(
            title: Localization.Dock.new,
            keyEquivalent: String(),
            keyModifier: [],
            action: #selector(new(_:)),
            target: self,
            isEnabled: true
        )
        return menuItem
    }
    
    private func getWindowMenuItem(title: String) -> MenuItem {
        let menuItem = MenuItem(
            title: title,
            keyEquivalent: String(),
            keyModifier: [],
            action: #selector(openWindow(_:)),
            target: self,
            isEnabled: true
        )
        return menuItem
    }
}
