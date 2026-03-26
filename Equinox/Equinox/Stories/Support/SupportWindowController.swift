// Copyright (c) 2026 Dzmitry Miadziukha
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

protocol SupportWindowControllerDelegate: AnyObject {
    func supportWindowDidClose()
}

// MARK: - Enums, Structs

extension SupportWindowController {
    private enum Constants {
        static let minSize = NSSize(width: 452, height: 421)
    }
}

// MARK: - Class

final class SupportWindowController: WindowController {
    private let supportService: SupportService
    private var contentWindow: Window?
    private var toolBarController: ToolbarController?
    
    init(supportService: SupportService) {
        self.supportService = supportService
        super.init(window: nil)
        setupWindow()
    }
    
    // MARK: - Setup
    
    private func setupWindow() {
        let controller = SupportRootViewController(supportService: supportService)
        controller.delegate = self
        
        contentWindow = Window(contentViewController: controller, minSize: Constants.minSize)
        contentWindow?.styleMask.remove(.resizable)
        let toolBarController = ToolbarController(identifier: NSToolbar.Identifier("SupportToolbar"))
        self.toolBarController = toolBarController
        contentWindow?.toolbar = toolBarController.toolbar
        contentWindow?.titlebarAppearsTransparent = true
        
        window = contentWindow
        let title = Localization.Support.title
        window?.title = title
        window?.miniwindowTitle = title
        window?.standardWindowButton(.zoomButton)?.isHidden = true
        window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window?.makeKeyAndOrderFront(self)
        window?.center()
    }
    
    // MARK: - Public
    
    weak var delegate: SupportWindowControllerDelegate?
    
    // MARK: - Private
    
    private func resizeToFitContent() {
        guard let window, let contentView = window.contentViewController?.view else {
            return
        }

        contentView.layoutSubtreeIfNeeded()
        var size = contentView.fittingSize
        size.width = Constants.minSize.width
        size.height = max(size.height, Constants.minSize.height)

        window.setContentSize(size)
    }
}

// MARK: - SupportWindowControllerDelegate

extension SupportWindowController: SupportRootViewControllerDelegate {
    func supportRootViewControllerDidClose() {
        delegate?.supportWindowDidClose()
    }
    
    func supportRootViewControllerResizeWindowToFitContent() {
        resizeToFitContent()
    }
}
