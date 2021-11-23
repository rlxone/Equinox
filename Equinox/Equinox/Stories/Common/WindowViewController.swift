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
import EquinoxAssets
import EquinoxUI

final class WindowViewController: ViewController {
    private let windowTitle: String
    private let contentViewController: ViewController

    private lazy var contentView: WindowContentView = {
        let view = WindowContentView()
        view.style = .init(
            titleBarStyle: .init(
                titleStyle: .init(
                    font: Font.body(.medium),
                    activeColor: Color.label,
                    inactiveColor: Color.tertiaryLabel
                ),
                titleLineStyle: .init(
                    firstColor: Color.titleBorder1,
                    secondColor: Color.titleBorder2
                )
            ),
            notificationStyle: .init(
                ownStyle: .init(
                    borderColor: Color.notificationBorder
                ),
                textStyle: .init(
                    font: Font.body(.regular),
                    color: Color.label
                )
            )
        )
        return view
    }()

    // MARK: - Initializer

    init(contentViewController: ViewController, windowTitle: String) {
        self.windowTitle = windowTitle
        self.contentViewController = contentViewController
        super.init()
        setup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = contentView
    }

    // MARK: - Setup

    private func setup() {
        setupView()
        setupController()
        setupNotifications()
    }

    private func setupView() {
        contentView.title = windowTitle
    }

    private func setupController() {
        addChild(contentViewController)
        contentView.containerView.addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentViewController.view.leadingAnchor.constraint(equalTo: contentView.containerView.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: contentView.containerView.trailingAnchor),
            contentViewController.view.topAnchor.constraint(equalTo: contentView.containerView.topAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: contentView.containerView.bottomAnchor)
        ])
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    // MARK: - Public

    public func notify(_ text: String) {
        contentView.notify(text)
    }

    // MARK: - Actions

    @objc
    func didBecomeActive(_ notification: Notification) {
        contentView.active = true
    }

    @objc
    func didResignActive(_ notification: Notification) {
        contentView.active = false
    }
}
