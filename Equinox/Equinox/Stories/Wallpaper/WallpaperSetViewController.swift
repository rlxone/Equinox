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

protocol WallpaperSetViewControllerDelegate: AnyObject {
    func setViewControllerContinueWasInteracted(skip: Bool)
}

// MARK: - Enums, Structs

extension WallpaperSetViewController {
    private enum Constants {
        static let desktopLinkTag = "openpane"
        static let preferencesIdentifer = "com.apple.systempreferences"
        static let desktopPreferencesPanePath = "/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane"
    }
}

// MARK: - Class

final class WallpaperSetViewController: ViewController {
    private lazy var contentView: SetContentView = {
        let view = SetContentView()
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
        contentView.title = Localization.Wallpaper.Set.title
        if #available(macOS 13, *) {
            contentView.descriptionTitle = Localization.Wallpaper.Set.descriptionTitle
            contentView.todoText = Localization.Wallpaper.Set.todo
            contentView.links = [
                .init(text: Localization.Wallpaper.Set.todoLink, tag: Constants.desktopLinkTag)
            ]
        } else {
            contentView.descriptionTitle = Localization.Wallpaper.Set.descriptionTitleOld
            contentView.todoText = Localization.Wallpaper.Set.todoOld
            contentView.links = [
                .init(text: Localization.Wallpaper.Set.todoLinkOld, tag: Constants.desktopLinkTag)
            ]
        }
        contentView.buttonTitle = Localization.Wallpaper.Set.continue
        contentView.image = Image.setTip
        contentView.skipText = Localization.Wallpaper.Set.skip
    }
    
    private func setupActions() {
        contentView.action = { [weak self] skip in
            self?.delegate?.setViewControllerContinueWasInteracted(skip: skip)
        }
        
        contentView.todoClickAction = { [weak self] link in
            guard
                let tag = (link as? URL)?.absoluteString,
                tag == Constants.desktopLinkTag
            else {
                return
            }
            self?.openDesktopPreferencesPane()
        }
    }
    
    // MARK: - Public
    
    weak var delegate: WallpaperSetViewControllerDelegate?
    
    // MARK: - Private
    
    private func openDesktopPreferencesPane() {
        WorkspaceRunner.shell("open -b \(Constants.preferencesIdentifer) \(Constants.desktopPreferencesPanePath)")
    }
}
