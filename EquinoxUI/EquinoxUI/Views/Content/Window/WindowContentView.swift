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

extension WindowContentView {
    public struct Style {
        let titleBarStyle: TitleBarView.Style
        let notificationStyle: NotificationView.Style

        public init(titleBarStyle: TitleBarView.Style, notificationStyle: NotificationView.Style) {
            self.titleBarStyle = titleBarStyle
            self.notificationStyle = notificationStyle
        }
    }

    private enum Constants {
        static let titleBarHeight: CGFloat = 38
        static let notificationDelay = 3
        static let notificationTopOffset: CGFloat = 86
        static let hiddenNotificationTopOffset: CGFloat = 16
        static let presentAnimationDuration: TimeInterval = 0.2
    }
}

// MARK: - Class

public final class WindowContentView: VisualEffectView {
    private lazy var titleBarView = TitleBarView()
    private lazy var notificationView = NotificationView()
    private lazy var notificationQueue = OperationQueue()
    private lazy var notificationSemaphore = DispatchSemaphore(value: 0)
    private weak var notificationTopConstraint: NSLayoutConstraint?
    public lazy var containerView = NSView()

    // MARK: - Initializer

    public init() {
        super.init(material: .windowBackground, blendingMode: .behindWindow)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupConstraints()
        setupActions()
    }

    private func setupView() {
        addSubview(containerView)
        addSubview(notificationView)
        addSubview(titleBarView)
    }

    private func setupConstraints() {
        titleBarView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        notificationView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            notificationView.centerXAnchor.constraint(equalTo: centerXAnchor),

            titleBarView.topAnchor.constraint(equalTo: topAnchor),
            titleBarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleBarView.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleBarView.heightAnchor.constraint(equalToConstant: Constants.titleBarHeight),

            containerView.topAnchor.constraint(equalTo: titleBarView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        notificationTopConstraint = notificationView.topAnchor.constraint(
            equalTo: titleBarView.bottomAnchor,
            constant: -Constants.notificationTopOffset
        )
        notificationTopConstraint?.isActive = true
    }
    
    private func setupActions() {
        notificationView.action = { [weak self] in
            self?.notificationQueue.cancelAllOperations()
            self?.animateDismiss()
        }
    }

    // MARK: - Public
    
    public var style: Style? {
        didSet {
            titleBarView.style = style?.titleBarStyle
            notificationView.style = style?.notificationStyle
        }
    }
    
    public override var active: Bool {
        get {
            return super.active
        }
        set {
            super.active = newValue
            titleBarView.active = newValue
        }
    }

    public var title: String {
        get {
            return titleBarView.title
        }
        set {
            titleBarView.title = newValue
        }
    }

    public func notify(_ text: String) {
        notificationView.text = text

        notificationQueue.cancelAllOperations()
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak self, weak operation] in
            guard let operation = operation, !operation.isCancelled else {
                return
            }
            
            OperationQueue.main.addOperation {
                self?.animatePresent()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Constants.notificationDelay)) { [weak operation] in
                guard let operation = operation, !operation.isCancelled else {
                    self?.notificationSemaphore.signal()
                    return
                }
                self?.animateDismiss()
                self?.notificationSemaphore.signal()
            }
            
            self?.notificationSemaphore.wait()
        }

        notificationQueue.addOperation(operation)
    }
    
    // MARK: - Private
    
    private func animatePresent() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constants.presentAnimationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            self.notificationTopConstraint?.animator().constant = Constants.hiddenNotificationTopOffset
        }
    }
    
    private func animateDismiss() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Constants.presentAnimationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            self.notificationTopConstraint?.animator().constant = -Constants.notificationTopOffset
        }
    }
}
