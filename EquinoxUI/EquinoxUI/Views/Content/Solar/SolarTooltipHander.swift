// Copyright (c) 2024 Dmitry Meduho
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

final class SolarTooltipHander {
    public var style: TooltipWindow.Style?
    
    public var daylightSavingTimeTitle: String?
    public var daylightSavingTimeDescription: String?
    public var abbreviationTitle: String?
    public var abbreviationDescription: String?
    public var dragAndDropTitle: String?
    public var dragAndDropDescription: String?
}

// MARK: - TooltipDelegate

extension SolarTooltipHander: TooltipDelegate {
    func tooltipTitle(_ sender: NSView?) -> String {
        guard 
            let tooltipable = sender as? Tooltipable,
            let identifier = tooltipable.tooltipIdentifier
        else {
            return String()
        }
        
        let title: String?
        
        switch identifier {
        case SolarMainContentView.TooltipIdentifier.daylightSavingTime.rawValue:
            title = daylightSavingTimeTitle
        case SolarMainContentView.TooltipIdentifier.abbreviation.rawValue:
            title = abbreviationTitle
        case SolarMainContentView.TooltipIdentifier.dragAndDrop.rawValue:
            title = dragAndDropTitle
        default:
            title = String()
        }
        
        return title ?? String()
    }
    
    func tooltipDescription(_ sender: NSView?) -> String {
        guard
            let tooltipable = sender as? Tooltipable,
            let identifier = tooltipable.tooltipIdentifier
        else {
            return String()
        }
        
        let description: String?
        
        switch identifier {
        case SolarMainContentView.TooltipIdentifier.daylightSavingTime.rawValue:
            description = daylightSavingTimeDescription
        case SolarMainContentView.TooltipIdentifier.abbreviation.rawValue:
            description = abbreviationDescription
        case SolarMainContentView.TooltipIdentifier.dragAndDrop.rawValue:
            description = dragAndDropDescription
        default:
            description = String()
        }
        
        return description ?? String()
    }

    func tooltipViewForFooter(_ sender: NSView?) -> NSView? {
        return nil
    }

    func tooltipWillDisplayView(_ sender: NSView?, view: NSView) {
    }
    
    func tooltipStyle(_ sender: NSView?) -> TooltipWindow.Style? {
        return style
    }
}
