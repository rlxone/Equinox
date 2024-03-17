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

// MARK: - Protocols

public protocol Tooltipable: AnyObject {
    var tooltipIdentifier: String? { get set }
    var showTooltip: Bool { get set }
    var tooltipPresentDelayMilliseconds: Int { get set }
    var tooltipDelegate: TooltipDelegate? { get set }
}

public protocol TooltipDelegate: AnyObject {
    func tooltipTitle(_ sender: NSView?) -> String
    func tooltipDescription(_ sender: NSView?) -> String
    func tooltipViewForFooter(_ sender: NSView?) -> NSView?
    func tooltipWillDisplayView(_ sender: NSView?, view: NSView)
    func tooltipStyle(_ sender: NSView?) -> TooltipWindow.Style?
}

// MARK: - Class

final class TooltipPresenter {
    private weak var view: NSView?
    private var trackingArea: NSTrackingArea?
    private var tooltipWindow: TooltipWindow?
    private var isTooltipVisible = false
    private var isMouseEntered = false
    private var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private var semaphore = DispatchSemaphore(value: 0)
    
    init(view: NSView) {
        self.view = view
        let trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [
                .mouseEnteredAndExited,
                .activeAlways
            ],
            owner: view,
            userInfo: nil
        )
        view.addTrackingArea(trackingArea)
    }
    
    // MARK: - Life Cycle
    
    func updateTrackingAreas() {
        guard let view = view, let window = view.window else {
            return
        }
        operationQueue.cancelAllOperations()
        if let area = trackingArea {
            view.removeTrackingArea(area)
        }
        let area = NSTrackingArea(
            rect: view.bounds,
            options: [
                .mouseEnteredAndExited,
                .activeAlways
            ],
            owner: view,
            userInfo: nil
        )
        trackingArea = area
        view.addTrackingArea(area)
        var mouseLocation = window.mouseLocationOutsideOfEventStream
        mouseLocation = view.convert(mouseLocation, to: nil)
        if view.bounds.contains(mouseLocation) {
            mouseEntered()
        } else if isTooltipVisible {
            mouseExited()
        }
    }
    
    func mouseUp() {
        isMouseEntered = false
        operationQueue.cancelAllOperations()
        hideTooltip()
    }

    func mouseDown() {
        isMouseEntered = false
        operationQueue.cancelAllOperations()
        hideTooltip()
    }
    
    func mouseEntered() {
        isMouseEntered = true

        operationQueue.cancelAllOperations()
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak self, weak operation] in
            guard let self = self, let operation = operation, !operation.isCancelled else {
                return
            }
            let deadline: DispatchTime = .now() + .milliseconds(self.presentDelayMilliseconds)
            DispatchQueue.main.asyncAfter(deadline: deadline) { [weak operation] in
                guard let operation = operation, !operation.isCancelled else {
                    self.semaphore.signal()
                    return
                }
                self.showTooltip()
                self.semaphore.signal()
            }
            self.semaphore.wait()
        }

        operationQueue.addOperation(operation)
    }
    
    func mouseExited() {
        isMouseEntered = false
        operationQueue.cancelAllOperations()
        hideTooltip()
    }
    
    // MARK: - Public
    
    weak var tooltipDelegate: TooltipDelegate?
    
    var presentDelayMilliseconds = 0
    
    // MARK: - Private
    
    private var centerRelativePoint: NSPoint? {
        guard let view = view, let window = view.window else {
            return nil
        }
        let viewFrame = view.convert(view.bounds, to: nil)
        let offsetX = window.frame.origin.x + viewFrame.origin.x + viewFrame.width / 2
        let offsetY = window.frame.origin.y + viewFrame.origin.y + viewFrame.height
        return NSPoint(x: offsetX, y: offsetY)
    }

    private func showTooltip() {
        guard
            let view = view,
            let window = view.window,
            isMouseEntered,
            tooltipWindow == nil,
            let centerPoint = centerRelativePoint,
            let delegate = tooltipDelegate
        else {
            return
        }

        guard
            let convertedPoint = window.contentView?.convert(window.mouseLocationOutsideOfEventStream, from: window.contentView),
            let hitView = window.contentView?.hitTest(convertedPoint),
            hitView.isDescendant(of: view)
        else {
            return
        }

        let tooltipWindow = TooltipWindow()
        tooltipWindow.style = delegate.tooltipStyle(view)
        if let footerView = delegate.tooltipViewForFooter(view) {
            delegate.tooltipWillDisplayView(view, view: footerView)
            tooltipWindow.tooltipView?.footerView = footerView
        }
        tooltipWindow.tooltipView?.setText(
            title: delegate.tooltipTitle(view),
            description: delegate.tooltipDescription(view)
        )
        tooltipWindow.setWindowFrame(relativeTo: centerPoint)

        window.addChildWindow(tooltipWindow, ordered: .above)
        tooltipWindow.present(animated: true)

        self.tooltipWindow = tooltipWindow

        isTooltipVisible = true
    }

    private func hideTooltip() {
        tooltipWindow?.close()
        tooltipWindow = nil
        isTooltipVisible = false
    }
}
