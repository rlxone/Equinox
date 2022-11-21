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

import EquinoxAssets
import EquinoxCore
import EquinoxUI
import Foundation

// MARK: - Protocols

protocol SolarRootViewControllerDelegate: AnyObject {
    func rootViewControllerShouldNotify(_ text: String)
}

// MARK: - Class

final class SolarRootViewController: ViewController {
    private let solarService: SolarService
    private let settingsService: SettingsService

    private lazy var contentView = RootContentView()
    private weak var navigationController: NavigationController?
    private weak var tipViewController: TipViewController?

    // MARK: - Initializer

    init(solarService: SolarService, settingsService: SettingsService) {
        self.solarService = solarService
        self.settingsService = settingsService
        super.init()
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    private func setup() {
        presentTypeController()
        presentTipIfNeeded()
    }

    // MARK: - Public

    weak var delegate: SolarRootViewControllerDelegate?

    // MARK: - Private

    private func presentTypeController() {
        let controller = SolarMainViewController(solarService: solarService)
        controller.delegate = self
        let navigationController = NavigationController(rootViewController: controller)
        self.navigationController = navigationController
        addChildController(navigationController, container: view)
    }

    private func presentTipIfNeeded() {
        let hasWalkthrough = settingsService.hasWalkthrough(type: .solarCalculator)

        if !hasWalkthrough {
            presentTip(firstPresent: true, animated: false)
        }
    }

    private func presentTip(firstPresent: Bool, animated: Bool) {
        let title = Localization.Tip.Calculator.title
        let description = Localization.Tip.Calculator.description
        let image = Image.calculatorTip
        let status = Localization.Tip.Shared.tips
        let buttonTitle = firstPresent ? Localization.Tip.Shared.started : Localization.Tip.Shared.ok

        let controller = TipViewController(
            model: .init(
                title: title,
                description: description,
                status: status,
                buttonTitle: buttonTitle,
                image: image
            )
        )
        controller.delegate = self
        tipViewController = controller

        navigationController?.present(controller, animated: animated)
    }
}

// MARK: - SolarViewControllerDelegate

extension SolarRootViewController: SolarMainViewControllerDelegatae {
    func solarViewControllerShouldNotify(_ text: String) {
        delegate?.rootViewControllerShouldNotify(text)
    }

    func solarViewControllerHelpWasInteracted() {
        presentTip(firstPresent: false, animated: true)
    }
}

extension SolarRootViewController: TipViewControllerDelegate {
    func getStartedWasInteracted() {
        guard let tipViewController = tipViewController else {
            return
        }
        settingsService.setWalkthrough(type: .solarCalculator)
        navigationController?.dismiss(tipViewController, animated: true)
    }
}
