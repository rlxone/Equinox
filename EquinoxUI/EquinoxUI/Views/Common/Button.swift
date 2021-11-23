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

// MARK: - Protocols

public protocol TooltipDelegate: AnyObject {
    func tooltipTitle(_ sender: Any?) -> String
    func tooltipDescription(_ sender: Any?) -> String
    func tooltipViewForFooter(_ sender: Any?) -> NSView?
    func tooltipWillDisplayView(_ sender: Any?, view: NSView)
    func tooltipStyle(_ sender: Any?) -> TooltipWindow.Style?
}

// MARK: - Enums, Structs

extension Button {
    public typealias Action = (Button) -> Void

    private enum Constants {
        static let presentDelayMilliseconds = 1_200
    }
}

// MARK: - Class

public class Button: NSButton {
    private var trackingArea: NSTrackingArea?
    private var tooltipWindow: TooltipWindow?
    private var isTooltipVisible = false
    private var isMouseEntered = false
    private var operationQueue = OperationQueue()
    private var semaphore = DispatchSemaphore(value: 0)
    
    // MARK: - Initializer
    
    public init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    public override func updateTrackingAreas() {
        guard let window = window else {
            super.updateTrackingAreas()
            return
        }
        operationQueue.cancelAllOperations()
        if let area = trackingArea {
            removeTrackingArea(area)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [
                .mouseEnteredAndExited,
                .activeAlways
            ],
            owner: self,
            userInfo: nil
        )
        trackingArea = area
        addTrackingArea(area)
        var mouseLocation = window.mouseLocationOutsideOfEventStream
        mouseLocation = convert(mouseLocation, to: nil)
        if bounds.contains(mouseLocation) {
            mouseEntered()
        } else if isTooltipVisible {
            mouseExited()
        }
        super.updateTrackingAreas()
    }

    public override func mouseUp(with event: NSEvent) {
        if isEnabled {
            onAction?(self)
        }
        isMouseEntered = false
        operationQueue.cancelAllOperations()
        hideTooltip()
    }

    public override func mouseDown(with event: NSEvent) {
        isMouseEntered = false
        operationQueue.cancelAllOperations()
        hideTooltip()
    }

    public override func mouseEntered(with event: NSEvent) {
        mouseEntered()
    }

    public override func mouseExited(with event: NSEvent) {
        mouseExited()
    }

    // MARK: - Setup

    private func setup() {
        stringValue = String()
    }

    // MARK: - Public

    public weak var tooltipDelegate: TooltipDelegate?

    public var onAction: Action?

    // MARK: - Private
    
    private func mouseEntered() {
        isMouseEntered = true

        operationQueue.cancelAllOperations()
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak self, weak operation] in
            guard let operation = operation, !operation.isCancelled else {
                return
            }
            let deadline: DispatchTime = .now() + .milliseconds(Constants.presentDelayMilliseconds)
            DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self, weak operation] in
                guard let operation = operation, !operation.isCancelled else {
                    self?.semaphore.signal()
                    return
                }
                self?.showTooltip()
                self?.semaphore.signal()
            }
            self?.semaphore.wait()
        }

        operationQueue.addOperation(operation)
    }
    
    private func mouseExited() {
        isMouseEntered = false
        operationQueue.cancelAllOperations()
        hideTooltip()
    }
    
    private var centerRelativePoint: NSPoint? {
        guard let window = window else {
            return nil
        }
        let buttonFrame = convert(bounds, to: nil)
        let offsetX = window.frame.origin.x + buttonFrame.origin.x + buttonFrame.width / 2
        let offsetY = window.frame.origin.y + buttonFrame.origin.y + buttonFrame.height
        return NSPoint(x: offsetX, y: offsetY)
    }

    private func showTooltip() {
        guard
            let window = window,
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
            hitView == self
        else {
            return
        }

        let tooltipWindow = TooltipWindow()
        tooltipWindow.style = delegate.tooltipStyle(self)
        if let footerView = delegate.tooltipViewForFooter(self) {
            delegate.tooltipWillDisplayView(self, view: footerView)
            tooltipWindow.tooltipView?.footerView = footerView
        }
        tooltipWindow.tooltipView?.setText(
            title: delegate.tooltipTitle(self),
            description: delegate.tooltipDescription(self)
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
