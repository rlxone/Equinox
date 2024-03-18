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

public class ImageView: NSImageView, Tooltipable {
    private var tooltipPresenter: TooltipPresenter?
    
    public override func hitTest(_ point: NSPoint) -> NSView? {
        return isUserInteractionsEnabled ? super.hitTest(point) : nil
    }
    
    // MARK: - Life Cycle
    
    public override func updateTrackingAreas() {
        tooltipPresenter?.updateTrackingAreas()
        super.updateTrackingAreas()
    }
    
    public override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        tooltipPresenter?.mouseDown()
    }
    
    public override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        tooltipPresenter?.mouseDown()
    }

    public override func mouseEntered(with event: NSEvent) {
        tooltipPresenter?.mouseEntered()
    }

    public override func mouseExited(with event: NSEvent) {
        tooltipPresenter?.mouseExited()
    }
    
    // MARK: - Public

    public override var image: NSImage? {
        get {
            return super.image
        }
        set {
            super.image = newValue
            if imageContentsGravity != nil {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                layer?.contents = newValue
                CATransaction.commit()
            }
        }
    }

    public var isUserInteractionsEnabled = true

    public var imageContentsGravity: CALayerContentsGravity? {
        didSet {
            if let imageContentsGravity = imageContentsGravity {
                wantsLayer = true
                layer = CALayer()
                layer?.contentsGravity = imageContentsGravity
            }
        }
    }
    
    // MARK: - Tooltipable
    
    public var showTooltip = false {
        didSet {
            tooltipPresenter = showTooltip ? TooltipPresenter(view: self) : nil
        }
    }
    
    public var tooltipPresentDelayMilliseconds: Int = 0 {
        didSet {
            tooltipPresenter?.presentDelayMilliseconds = tooltipPresentDelayMilliseconds
        }
    }
    
    public weak var tooltipDelegate: TooltipDelegate? {
        didSet {
            tooltipPresenter?.tooltipDelegate = tooltipDelegate
        }
    }
    
    public var tooltipIdentifier: String?
}
