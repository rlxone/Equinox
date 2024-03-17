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
    public typealias ChangeAction = (MenuData.Item) -> Void
    
    public struct MenuData {
        public struct Item: Equatable {
            public var identifier: String
            public var title: String
            public var supplementaryTitle: String?
            
            public init(identifier: String, title: String, supplementaryTitle: String? = nil) {
                self.identifier = identifier
                self.title = title
                self.supplementaryTitle = supplementaryTitle
            }
        }
        
        var headerTitle: String
        var items: [String: [Item]]
        var selectedItem: Item
        
        public init(headerTitle: String, items: [String: [Item]], selectedItem: Item) {
            self.headerTitle = headerTitle
            self.items = items
            self.selectedItem = selectedItem
        }
    }
    
    public struct Style {
        let titleFont: NSFont
        let titleColor: NSColor
        let supplementaryTitleFont: NSFont?
        let supplementaryTitleColor: NSColor?
        
        public init(
            titleFont: NSFont,
            titleColor: NSColor,
            supplementaryTitleFont: NSFont? = nil,
            supplementaryTitleColor: NSColor? = nil
        ) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.supplementaryTitleFont = supplementaryTitleFont
            self.supplementaryTitleColor = supplementaryTitleColor
        }
    }
}

// MARK: - Class

public final class SubMenuPopUpButton: NSPopUpButton {
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
    
    public var style: Style?
    
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
        setAlternativeTitle(data.selectedItem.title)
        addSectionHeader(menu: menu, title: data.headerTitle)
        
        let sortedItems = data.items.sorted { $0.key < $1.key }
        
        for item in sortedItems {
            let itemMenu = NSMenu()
            let menuItem = NSMenuItem(title: String(), action: nil, keyEquivalent: String())
            menuItem.attributedTitle = formatTitleAttributedString(title: item.key)
            let sortedSubItems = item.value.sorted { $0.title < $1.title }
            
            for subItem in sortedSubItems {
                let subMenuItem = NSMenuItem(
                    title: subItem.title,
                    action: #selector(menuItemAction(_:)),
                    keyEquivalent: String()
                )
                subMenuItem.attributedTitle = formatAlternativeTitleAttributedString(item: subItem)
                subMenuItem.representedObject = subItem
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
    
    func addSectionHeader(menu: NSMenu, title: String) {
        if #available(macOS 14.0, *) {
            menu.addItem(.sectionHeader(title: title))
        } else {
            menu.autoenablesItems = false
            let headerItem = NSMenuItem(title: title, action: nil, keyEquivalent: String())
            headerItem.isEnabled = false
            menu.addItem(headerItem)
        }
    }
    
    private func setAlternativeTitle(_ title: String) {
        guard let cell = cell as? SubMenuPopUpButtonCell else {
            return
        }
        cell.selectedTitle = title
    }
    
    @objc
    private func menuItemAction(_ item: NSMenuItem) {
        guard let menuItem = item.representedObject as? MenuData.Item else {
            return
        }

        setAlternativeTitle(menuItem.title)
        data?.selectedItem = menuItem
        changeAction?(menuItem)
    }
    
    private func formatTitleAttributedString(title: String) -> NSAttributedString {
        guard let style = style else {
            return NSAttributedString()
        }
        
        return NSAttributedString(
            string: title,
            attributes: [
                .foregroundColor: style.titleColor,
                .font: style.titleFont
            ]
        )
    }
    
    private func formatAlternativeTitleAttributedString(item: MenuData.Item) -> NSAttributedString {
        guard let style = style else {
            return NSAttributedString()
        }
        
        let attributedTitle = NSMutableAttributedString()
        let title = NSAttributedString(
            string: item.title + " ",
            attributes: [
                .foregroundColor: style.titleColor,
                .font: style.titleFont
            ]
        )
        attributedTitle.append(title)
        if
            let supplementaryTitle = item.supplementaryTitle,
            let supplementaryTitleFont = style.supplementaryTitleFont,
            let supplementaryTitleColor = style.supplementaryTitleColor
        {
            let supplementaryString = NSAttributedString(
                string: supplementaryTitle,
                attributes: [
                    .foregroundColor: supplementaryTitleColor,
                    .font: supplementaryTitleFont
                ]
            )
            attributedTitle.append(supplementaryString)
        }
        return attributedTitle
    }
}
