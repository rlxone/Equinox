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
import EquinoxUI
import EquinoxAssets

class ToolbarController: NSObject {
    let toolbar: NSToolbar

    init(identifier: NSToolbar.Identifier) {
        toolbar = NSToolbar(identifier: identifier)
        super.init()
        setup()
    }
    
    private func setup() {
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        toolbar.displayMode = .iconOnly
        toolbar.showsBaselineSeparator = false
        
        if #available(macOS 15.0, *) {
            toolbar.allowsDisplayModeCustomization = false
        }
    }
}

extension NSToolbarItem.Identifier {
    static let title = NSToolbarItem.Identifier("Title")
    static let new = NSToolbarItem.Identifier("New")
    static let help = NSToolbarItem.Identifier("Help")
    static let calculator = NSToolbarItem.Identifier("Calculator")
    static let links = NSToolbarItem.Identifier("Links")
}

extension NSToolbarItem {
    static func title(text: String) -> NSToolbarItem {
        let titleLabel = Label(labelWithString: text)
        titleLabel.font = Font.title3(.semibold)
        titleLabel.textColor = Color.label
        titleLabel.lineBreakMode = .byTruncatingTail
        
        let item = NSToolbarItem(itemIdentifier: .title)
        item.view = titleLabel
        if #available(macOS 10.15, *) {
            item.isBordered = false
        }
        if #available(macOS 26.0, *) {
            item.style = .plain
        }
        item.visibilityPriority = .high
        return item
    }
    
    static func new() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .new)
        item.label = Localization.Toolbar.New.label
        item.paletteLabel = Localization.Toolbar.New.palette
        item.toolTip = Localization.Toolbar.New.toolTip
        item.image = getToolbarImage(systemSymbolName: "plus", fallbackImage: Image.plus)
        item.visibilityPriority = .high
        
        return item
    }
    
    static func help() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .help)
        item.label = Localization.Toolbar.Help.label
        item.paletteLabel = Localization.Toolbar.Help.palette
        item.toolTip = Localization.Toolbar.Help.toolTip
        item.image = getToolbarImage(systemSymbolName: "questionmark", fallbackImage: Image.questionMark)
        item.visibilityPriority = .high
        
        return item
    }
    
    static func calculator() -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .calculator)
        item.label = Localization.Toolbar.Calculator.label
        item.paletteLabel = Localization.Toolbar.Calculator.palette
        item.toolTip = Localization.Toolbar.Calculator.toolTip
        item.image = getToolbarImage(systemSymbolName: "graph.2d", fallbackImage: Image.calculator)
        item.visibilityPriority = .high

        return item
    }
    
    static func links(target: AnyObject, action: Selector) -> NSToolbarItem {
        let menu = makeHelpLinksMenu(target: target, action: action)
        let label = Localization.Toolbar.more
        let toolTip = Localization.Toolbar.more

        if #available(macOS 10.15, *) {
            let item = NSMenuToolbarItem(itemIdentifier: .links)
            item.menu = menu
            item.showsIndicator = false
            item.label = label
            item.paletteLabel = label
            item.toolTip = toolTip
            item.image = getToolbarImage(systemSymbolName: "ellipsis", fallbackImage: Image.ellipsis)
            item.visibilityPriority = .high
            
            return item
        }

        let item = NSToolbarItem(itemIdentifier: .links)
        let button = NSPopUpButton(frame: .zero, pullsDown: true)
        button.menu = menu
        button.title = ""
        button.bezelStyle = .texturedRounded
        button.imagePosition = .imageOnly
        
        item.image = getToolbarImage(systemSymbolName: "ellipsis", fallbackImage: Image.ellipsis)
        item.view = button
        item.label = label
        item.paletteLabel = label
        item.toolTip = toolTip
        item.visibilityPriority = .high
        return item
    }
    
    private static func getToolbarImage(systemSymbolName: String, fallbackImage: NSImage) -> NSImage {
        var image: NSImage?
        if #available(macOS 11.0, *) {
            image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil)
        }
        return image ?? fallbackImage
    }
}

extension NSToolbarItem {    
    private static func makeHelpLinksMenu(target: AnyObject, action: Selector) -> NSMenu {
        let menu = NSMenu()
        HelpMenuLinks.allCases.forEach { link in
            guard let url = link.linkInfo.url else {
                return
            }
            let item = NSMenuItem(
                title: link.linkInfo.title,
                action: action,
                keyEquivalent: ""
            )
            item.target = target
            item.representedObject = url
            menu.addItem(item)
        }
        let helpLinksSeparatorIndex = 3
        if menu.items.count > helpLinksSeparatorIndex {
            menu.insertItem(NSMenuItem.separator(), at: helpLinksSeparatorIndex)
        }
        return menu
    }
}
