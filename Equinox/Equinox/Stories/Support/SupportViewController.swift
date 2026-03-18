// Copyright (c) 2026 Dzmitry Miadziukha
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
import EquinoxCore
import EquinoxAssets
import EquinoxUI
import SpriteKit

// MARK: - Protocols

protocol SupportViewControllerDelegate: AnyObject {
    func supportViewControllerDidClose()
    func supportViewControllerResizeToFitContent()
}

// MARK: - Enums, Structs

extension SupportViewController {
    private enum Constants {
        static let donationLink = "https://www.paypal.com/donate/?hosted_button_id=UZNTZDS85EB9W"
    }
}

// MARK: - Public

final class SupportViewController: ViewController {
    private let supportService: SupportService
    private lazy var contentView: SupportContentView = {
        let view = SupportContentView()
        view.animatedImageDelegate = self
        view.style = .default
        return view
    }()

    init(supportService: SupportService) {
        self.supportService = supportService
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
        setupView()
        setupActions()
        if NSApplication.isAppStoreBuild {
            loadProducts()
        } else {
            setLocalProducts()
        }
    }

    private func setupView() {
        updateUI {
            contentView.particleImage = Image.confettiParticle
            contentView.heartParticleImage = Image.heartParticle
            
            if supportService.isSupported {
                contentView.avatarImage = Image.avatarSuccess
                contentView.titleText = Localization.Support.Shared.thankYouTitle
                contentView.descriptionFirstText = Localization.Support.Supported.firstDescription
                contentView.descriptionSecondText = Localization.Support.Shared.openSourceDescription
                contentView.descriptionThirdText = Localization.Support.Supported.thirdDescription
                contentView.startConfetti()
            } else {
                contentView.avatarImage = Image.avatar
                contentView.titleText = Localization.Support.Unsupported.title
                contentView.descriptionFirstText = Localization.Support.Shared.openSourceDescription
                contentView.descriptionSecondText = Localization.Support.Unsupported.secondDescription
                contentView.descriptionThirdText = Localization.Support.Unsupported.thirdDescription
            }
            
            contentView.closeButtonText = Localization.Support.Shared.close
        }
    }

    private func setupActions() {
        contentView.closeAction = { [weak self] _ in
            self?.delegate?.supportViewControllerDidClose()
        }
        contentView.optionAction = { [weak self] option in
            if NSApplication.isAppStoreBuild {
                self?.purchase(option: option)
            } else {
                guard let url = URL(string: Constants.donationLink) else {
                    return
                }
                
                NSWorkspace.shared.open(url)
                
                self?.contentView.deselectAllOptions()
            }
        }
    }

    // MARK: - Public

    weak var delegate: SupportViewControllerDelegate?

    // MARK: - Private
    
    private func loadProducts() {
        contentView.setState(state: .loading, animated: false)

        supportService.loadProducts { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let productItems):
                    self?.setProducts(productItems: productItems)
                case .failure:
                    self?.setNoProductsAvailable()
                }
            }
        }
    }

    private func purchase(option: SupportContentView.Option) {
        contentView.setState(state: .loading, animated: true)

        let item = ProductItem(option: option)
        supportService.purchase(item: item) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let productItem):
                    self?.setSuccessfulPurchase(productItem: productItem)
                case .failure:
                    self?.setFailedPurchase()
                }
            }
        }
    }
    
    private func setLocalProducts() {
        self.setProducts(
            productItems: [
                ProductItem(
                    id: "donation",
                    title: Localization.Support.LocalProduct.title,
                    price: "$1.99+"
                )
            ]
        )
    }

    private func setProducts(productItems: [ProductItem]) {
        updateUI {
            contentView.options = productItems.map { SupportContentView.Option(item: $0) }
            contentView.beginAnimation()
            contentView.setState(state: .default, animated: true)
        }
    }
    
    private func setNoProductsAvailable() {
        updateUI {
            contentView.titleText = Localization.Support.NoProducts.title
            contentView.descriptionFirstText = Localization.Support.NoProducts.firstDescription
            contentView.descriptionSecondText = Localization.Support.NoProducts.secondDescription
            contentView.descriptionThirdText = Localization.Support.NoProducts.thirdDescription
            contentView.options = []
            contentView.beginAnimation()
            contentView.setState(state: .default, animated: true)
        }
    }

    private func setSuccessfulPurchase(productItem: ProductItem) {
        updateUI {
            contentView.titleText = Localization.Support.Shared.thankYouTitle
            contentView.descriptionFirstText = Localization.Support.PurchaseSuccess.firstDescription
            contentView.descriptionSecondText = Localization.Support.PurchaseSuccess.secondDescription
            contentView.descriptionThirdText = Localization.Support.PurchaseSuccess.thirdDescription
            contentView.avatarImage = Image.avatarSuccess
            contentView.options = []
            contentView.startConfetti()
            contentView.setState(state: .default, animated: true)
        }
    }
    
    private func setFailedPurchase() {
        updateUI {
            contentView.titleText = Localization.Support.PurchaseFailure.title
            contentView.descriptionFirstText = Localization.Support.PurchaseFailure.firstDescription
            contentView.descriptionSecondText = Localization.Support.PurchaseFailure.secondDescription
            contentView.descriptionThirdText = Localization.Support.PurchaseFailure.thirdDescription
            
            contentView.deselectAllOptions()
            contentView.setState(state: .default, animated: true)
        }
    }

    private var animatedImages: [NSImage] {
        return NSApp.isDarkMode ? [Image.support2, Image.support1] : [Image.support1, Image.support2]
    }
    
    private func updateUI(_ block: () -> Void) {
        block()
        delegate?.supportViewControllerResizeToFitContent()
    }
}

// MARK: - AnimatedImageViewDelegate

extension SupportViewController: AnimatedImageViewDelegate {
    func numberOfImages() -> Int {
        return animatedImages.count
    }

    func image(for index: Int, completion: @escaping (NSImage?) -> Void) {
        let image = animatedImages[index]
        completion(image)
    }
}

// MARK: - SupportContentView.Option

extension SupportContentView.Option {
    init(item: ProductItem) {
        self.init(
            id: item.id,
            title: item.price,
            description: item.title
        )
    }
}

// MARK: - ProductItem

extension ProductItem {
    init(option: SupportContentView.Option) {
        self.init(
            id: option.id,
            title: option.description,
            price: option.title
        )
    }
}
