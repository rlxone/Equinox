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

public class View: NSView, Tooltipable {
    private var tooltipPresenter: TooltipPresenter?
    
    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    public override func updateTrackingAreas() {
        tooltipPresenter?.updateTrackingAreas()
        super.updateTrackingAreas()
    }
    
    public override func mouseDown(with event: NSEvent) {
        if isUserInteractionsEnabled {
            super.mouseDown(with: event)
        }
        tooltipPresenter?.mouseDown()
    }
    
    public override func mouseUp(with event: NSEvent) {
        if isUserInteractionsEnabled {
            super.mouseUp(with: event)
        }
        tooltipPresenter?.mouseDown()
    }

    public override func mouseEntered(with event: NSEvent) {
        tooltipPresenter?.mouseEntered()
    }

    public override func mouseExited(with event: NSEvent) {
        tooltipPresenter?.mouseExited()
    }
    
    // MARK: - Public

    public var isUserInteractionsEnabled = true
    
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
