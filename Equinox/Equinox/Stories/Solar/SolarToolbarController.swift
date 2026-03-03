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

protocol SolarToolbarControllerDelegate: AnyObject {
    func solarToolbarControllerHelpWasInteracted(_ controller: SolarToolbarController)
}

final class SolarToolbarController: ToolbarController {
    private let title: String
    
    weak var delegate: SolarToolbarControllerDelegate?
    
    init(title: String) {
        self.title = title
        super.init(identifier: NSToolbar.Identifier("SolarToolbar"))
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        toolbar.delegate = self
    }
    
    @objc
    private func helpInteracted(_ sender: Any?) {
        delegate?.solarToolbarControllerHelpWasInteracted(self)
    }
    
    @objc
    private func openLink(_ sender: NSMenuItem) {
        guard let url = sender.representedObject as? URL else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}

// MARK: - NSToolbarDelegate

extension SolarToolbarController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.title, .flexibleSpace, .links, .help]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.title, .flexibleSpace, .links, .help]
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        switch itemIdentifier {
        case .title:
            return .title(text: title)
        case .links:
            return .links(target: self, action: #selector(openLink(_:)))
        case .help:
            let item = NSToolbarItem.help()
            item.target = self
            item.action = #selector(helpInteracted(_:))
            return item
        default:
            return NSToolbarItem(itemIdentifier: itemIdentifier)
        }
    }
}
