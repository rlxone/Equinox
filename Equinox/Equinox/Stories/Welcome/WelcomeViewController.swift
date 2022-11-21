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

// MARK: - Protocols

protocol WelcomeViewControllerDelegate: AnyObject {
    func welcomeViewControllerTypeWasSelected(type: WallpaperType)
}

// MARK: - Enums, Structs

extension WelcomeViewController {
    private enum Constants {
        static let githubUrl = "https://github.com/rlxone/Equinox"
    }
}

// MARK: - Public

final class WelcomeViewController: ViewController {
    private lazy var contentView: WelcomeContentView = {
        let view = WelcomeContentView()
        view.style = .default
        return view
    }()

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
        setupView()
        setupActions()
    }

    private func setupView() {
        contentView.welcomeText = Localization.Welcome.welcome(param1: NSApplication.appName)
        contentView.versionText = Localization.Welcome.version(param1: NSApplication.appVersion)
        contentView.githubText = Localization.Welcome.github
        contentView.typeHeaderText = Localization.Welcome.choose
        contentView.typeDescriptionText = Localization.Welcome.select

        contentView.types = WallpaperType.allCases.map {
            switch $0 {
            case .solar:
                return TypeItemView.Item(
                    image: Image.solar,
                    title: Localization.Welcome.solar,
                    description: Localization.Welcome.solarDescription
                )

            case .time:
                return TypeItemView.Item(
                    image: Image.time,
                    title: Localization.Welcome.time,
                    description: Localization.Welcome.timeDescription
                )

            case .appearance:
                return TypeItemView.Item(
                    image: Image.appearance,
                    title: Localization.Welcome.appearance,
                    description: Localization.Welcome.appearanceDescription
                )
            }
        }

        contentView.selectedTypeIndex = WallpaperType.solar.rawValue
    }

    private func setupActions() {
        contentView.typeAction = { [weak self] selectedIndex in
            guard let type = WallpaperType(rawValue: selectedIndex) else {
                return
            }
            self?.delegate?.welcomeViewControllerTypeWasSelected(type: type)
        }
        contentView.githubAction = { _ in
            guard let url = URL(string: Constants.githubUrl) else {
                return
            }
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Public

    weak var delegate: WelcomeViewControllerDelegate?
}
