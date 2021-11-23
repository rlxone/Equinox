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

// MARK: - Enums, Structs

extension SubMenuPopUpButton {
    public typealias ChangeAction = (String) -> Void
    
    public struct MenuData {
        var items: [String: [String]]
        var selectedItem: String
        
        public init(items: [String: [String]], selectedItem: String) {
            self.items = items
            self.selectedItem = selectedItem
        }
    }
}

// MARK: - Class

public class SubMenuPopUpButton: NSPopUpButton {
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    public override init(frame buttonFrame: NSRect, pullsDown flag: Bool) {
        super.init(frame: buttonFrame, pullsDown: flag)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        cell = SubMenuPopUpButtonCell()
    }
    
    // MARK: - Public
    
    public var data: MenuData? {
        didSet {
            reloadData()
        }
    }
    
    public var changeAction: ChangeAction?
    
    // MARK: - Private
    
    private func reloadData() {
        guard let data = data else {
            return
        }
        
        let menu = NSMenu()
        setAlternativeTitle(data.selectedItem)
        let sortedItems = data.items.sorted { $0.key < $1.key }
        
        for item in sortedItems {
            let itemMenu = NSMenu()
            let menuItem = NSMenuItem(title: item.key, action: nil, keyEquivalent: String())
            let sortedSubItems = item.value.sorted { $0 < $1 }
            
            for subItem in sortedSubItems {
                let subMenuItem = NSMenuItem(
                    title: subItem,
                    action: #selector(menuItemAction(_:)),
                    keyEquivalent: String()
                )
                if subItem == data.selectedItem {
                    subMenuItem.state = .on
                    menuItem.state = .on
                }
                subMenuItem.target = self
                itemMenu.addItem(subMenuItem)
            }
            menuItem.submenu = itemMenu
            menu.addItem(menuItem)
        }
        
        self.menu = menu
    }
    
    private func setAlternativeTitle(_ title: String) {
        guard let cell = cell as? SubMenuPopUpButtonCell else {
            return
        }
        cell.selectedTitle = title
    }
    
    @objc
    private func menuItemAction(_ item: NSMenuItem) {
        setAlternativeTitle(item.title)
        data?.selectedItem = item.title
        changeAction?(item.title)
    }
}

// MARK: - NSMenuDelegate

extension SubMenuPopUpButton: NSMenuDelegate {
    public func menuWillOpen(_ menu: NSMenu) {
        reloadData()
    }
}
