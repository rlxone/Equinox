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

// swiftlint:disable force_unwrapping

public enum Color {
    public static let label = NSColor.labelColor
    public static let secondaryLabel = NSColor.secondaryLabelColor
    public static let tertiaryLabel = NSColor.tertiaryLabelColor
    public static let quaternaryLabel = NSColor.quaternaryLabelColor
    public static let clear = NSColor.clear
    public static let controlAccent = NSColor.controlAccentColor

    public static let titleBorder1 = bundleColor(named: "TitleBorder1")
    public static let titleBorder2 = bundleColor(named: "TitleBorder2")
    public static let separator = bundleColor(named: "Separator")
    public static let appearanceSeparator = bundleColor(named: "AppearanceSeparator")
    public static let wallpaperContent = bundleColor(named: "WallpaperContent")
    public static let wallpaperContentBorder = bundleColor(named: "WallpaperContentBorder")
    public static let wallpaperDash = bundleColor(named: "WallpaperDash")
    public static let wallpaperButtonBorder = bundleColor(named: "WallpaperButtonBorder")
    public static let wallpaperPrimaryBackground = bundleColor(named: "WallpaperPrimaryBackground")
    public static let wallpaperDynamicLight = bundleColor(named: "WallpaperDynamicLight")
    public static let wallpaperDynamicDark = bundleColor(named: "WallpaperDynamicDark")
    public static let wallpaperDynamicHighlight = bundleColor(named: "WallpaperDynamicHighlight")
    public static let buttonBackground = bundleColor(named: "ButtonBackground")
    public static let buttonBorder = bundleColor(named: "ButtonBorder")
    public static let buttonTextHighlight = bundleColor(named: "ButtonTextHighlight")
    public static let buttonTextGraphiteHighlight = bundleColor(named: "ButtonTextGraphiteHighlight")
    public static let buttonInnerShadow = bundleColor(named: "ButtonInnerShadow")
    public static let tabContent = bundleColor(named: "TabContent")
    public static let tabBorder = bundleColor(named: "TabBorder")
    public static let tabTextHighlight = bundleColor(named: "TabTextHighlight")
    public static let tabTextGraphiteHighlight = bundleColor(named: "TabTextGraphiteHighlight")
    public static let dragDash = bundleColor(named: "DragDash")
    public static let dragBackground = bundleColor(named: "DragBackground")
    public static let tooltipBorder = bundleColor(named: "TooltipBorder")
    public static let wallpaperBorder = bundleColor(named: "WallpaperBorder")
    public static let solarContent = bundleColor(named: "SolarContent")
    public static let solarContentBorder = bundleColor(named: "SolarContentBorder")
    public static let solarControlContent = bundleColor(named: "SolarControlContent")
    public static let solarControlContentBorder = bundleColor(named: "SolarControlContentBorder")
    public static let notificationBorder = bundleColor(named: "NotificationBorder")
    public static let typeSeparator = bundleColor(named: "TypeSeparator")
    public static let typeSelectedTint = bundleColor(named: "TypeSelectedTint")
    public static let typeImageContent = bundleColor(named: "TypeImageContent")
    public static let wallpaperFooterBackground = bundleColor(named: "WallpaperFooterBackground")
    public static let createOverlay = bundleColor(named: "CreateOverlay")
    public static let createSeparator = bundleColor(named: "CreateSeparator")
    public static let createOverlayBorder = bundleColor(named: "CreateOverlayBorder")
    public static let createDescriptionBackground = bundleColor(named: "CreateDescriptionBackground")
    public static let solarLine = bundleColor(named: "SolarLine")
    public static let solarChart = bundleColor(named: "SolarChart")
    public static let solarProgress = bundleColor(named: "SolarProgress")
    public static let tipOverlay = bundleColor(named: "TipOverlay")
    public static let tipSeparator = bundleColor(named: "TipSeparator")
    public static let lightBlue = bundleColor(named: "LightBlue")
}

// MARK: - Color

extension Color {
    private static func bundleColor(named id: String) -> NSColor {
        return NSColor(named: id, bundle: Bundler.current.bundle)!
    }
}

// swiftlint:enable force_unwrapping
