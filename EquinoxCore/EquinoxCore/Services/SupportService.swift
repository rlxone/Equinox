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

import StoreKit

// MARK: - Protocols

protocol SupportPaymentQueue: AnyObject {
    func add(_ observer: SKPaymentTransactionObserver)
    func remove(_ observer: SKPaymentTransactionObserver)
    func add(_ payment: SKPayment)
    func finishTransaction(_ transaction: SupportTransaction)
}

protocol SupportStoreProduct {
    var productIdentifier: String { get }
    var priceValue: Decimal { get }

    func productItem() -> ProductItem
    func payment() -> SKPayment
}

protocol SupportTransaction: AnyObject {
    var productIdentifier: String { get }
    var state: SupportTransactionState { get }
}

public protocol SupportService {
    func loadProducts(completion: @escaping (Result<[ProductItem], StoreError>) -> Void)
    func purchase(item: ProductItem, completion: @escaping (Result<ProductItem, StoreError>) -> Void)

    var isSupported: Bool { get }
}

// MARK: - Enums, Structs

extension SupportServiceImpl {
    enum Constants {
        static let supportKey = "support"
    }
}

enum SupportTransactionState {
    case purchased
    case failed
    case restored
    case deferred
    case purchasing
}

struct SupportTransactionResolution {
    let shouldFinishTransaction: Bool
    let shouldPersistSupport: Bool
    let purchaseResult: Result<ProductItem, StoreError>?
    let shouldClearActivePurchase: Bool
}

struct StoreKitProduct: SupportStoreProduct {
    let product: SKProduct

    var productIdentifier: String {
        return product.productIdentifier
    }

    var priceValue: Decimal {
        return product.price.decimalValue
    }

    func productItem() -> ProductItem {
        return ProductItem(product: product)
    }

    func payment() -> SKPayment {
        return SKPayment(product: product)
    }
}

// MARK: - Classes

final class StoreKitPaymentQueue: SupportPaymentQueue {
    private let paymentQueue: SKPaymentQueue

    init(paymentQueue: SKPaymentQueue = .default()) {
        self.paymentQueue = paymentQueue
    }

    func add(_ observer: SKPaymentTransactionObserver) {
        paymentQueue.add(observer)
    }

    func remove(_ observer: SKPaymentTransactionObserver) {
        paymentQueue.remove(observer)
    }

    func add(_ payment: SKPayment) {
        paymentQueue.add(payment)
    }

    func finishTransaction(_ transaction: SupportTransaction) {
        guard let transaction = transaction as? StoreKitTransaction else {
            return
        }

        paymentQueue.finishTransaction(transaction.transaction)
    }
}

final class StoreKitTransaction: SupportTransaction {
    let transaction: SKPaymentTransaction

    init(transaction: SKPaymentTransaction) {
        self.transaction = transaction
    }

    var productIdentifier: String {
        return transaction.payment.productIdentifier
    }

    var state: SupportTransactionState {
        switch transaction.transactionState {
        case .purchased:
            return .purchased
        case .failed:
            return .failed
        case .restored:
            return .restored
        case .deferred:
            return .deferred
        case .purchasing:
            return .purchasing
        @unknown default:
            return .purchasing
        }
    }
}

public class SupportServiceImpl: NSObject, SupportService {
    private let storageCore: StorageCore
    private let paymentQueue: SupportPaymentQueue
    private let supportProductIdentifiers: Set<String>

    private var products: [SupportStoreProduct] = []
    private var loadProductsCompletion: ((Result<[ProductItem], StoreError>) -> Void)?
    
    private var purchasingItem: ProductItem?
    private var purchaseCompletion: ((Result<ProductItem, StoreError>) -> Void)?
    
    public convenience init(storageCore: StorageCore) {
        self.init(
            storageCore: storageCore,
            paymentQueue: StoreKitPaymentQueue(),
            supportProductIdentifiers: SupportProductIdentifier.allIdentifiers
        )
    }

    init(
        storageCore: StorageCore,
        paymentQueue: SupportPaymentQueue,
        supportProductIdentifiers: Set<String> = SupportProductIdentifier.allIdentifiers
    ) {
        self.storageCore = storageCore
        self.paymentQueue = paymentQueue
        self.supportProductIdentifiers = supportProductIdentifiers
        super.init()
        paymentQueue.add(self)
    }
    
    deinit {
        paymentQueue.remove(self)
    }
    
    public func loadProducts(completion: @escaping (Result<[ProductItem], StoreError>) -> Void) {
        guard products.isEmpty else {
            let items = products.map { $0.productItem() }
            completion(.success(items))
            return
        }

        loadProductsCompletion = completion
        let request = SKProductsRequest(productIdentifiers: supportProductIdentifiers)
        request.delegate = self
        request.start()
    }
    
    public func purchase(item: ProductItem, completion: @escaping (Result<ProductItem, StoreError>) -> Void) {
        guard let product = products.first(where: { $0.productIdentifier == item.id }) else {
            return completion(.failure(.invalidProductIdentifier))
        }
        
        purchasingItem = item
        purchaseCompletion = completion
        paymentQueue.add(product.payment())
    }
    
    public var isSupported: Bool {
        do {
            return try storageCore.get(key: Constants.supportKey)
        } catch {
            return false
        }
    }

    var hasPendingPurchase: Bool {
        return purchasingItem != nil || purchaseCompletion != nil
    }

    func cacheProducts(_ products: [SupportStoreProduct]) {
        self.products = products.sorted { lhs, rhs in
            lhs.priceValue < rhs.priceValue
        }
    }

    @discardableResult
    func handleTransaction(_ transaction: SupportTransaction) -> SupportTransactionResolution {
        let resolution = resolveTransactionUpdate(
            state: transaction.state,
            productIdentifier: transaction.productIdentifier
        )

        if resolution.shouldPersistSupport {
            storageCore.set(key: Constants.supportKey, value: true)
        }

        if let purchaseResult = resolution.purchaseResult {
            purchaseCompletion?(purchaseResult)
        }

        if resolution.shouldClearActivePurchase {
            clearPendingPurchase()
        }

        if resolution.shouldFinishTransaction {
            paymentQueue.finishTransaction(transaction)
        }

        return resolution
    }

    func resolveTransactionUpdate(
        state: SupportTransactionState,
        productIdentifier: String
    ) -> SupportTransactionResolution {
        let isSupportTransaction = supportProductIdentifiers.contains(productIdentifier)
        let matchedPurchasingItem = purchasingItem?.id == productIdentifier ? purchasingItem : nil

        switch state {
        case .purchased:
            return SupportTransactionResolution(
                shouldFinishTransaction: true,
                shouldPersistSupport: isSupportTransaction,
                purchaseResult: matchedPurchasingItem.map(Result.success),
                shouldClearActivePurchase: matchedPurchasingItem != nil
            )
        case .failed:
            return SupportTransactionResolution(
                shouldFinishTransaction: true,
                shouldPersistSupport: false,
                purchaseResult: matchedPurchasingItem != nil ? .failure(.failedPurchase) : nil,
                shouldClearActivePurchase: matchedPurchasingItem != nil
            )
        case .restored:
            return SupportTransactionResolution(
                shouldFinishTransaction: true,
                shouldPersistSupport: isSupportTransaction,
                purchaseResult: nil,
                shouldClearActivePurchase: false
            )
        case .deferred, .purchasing:
            return SupportTransactionResolution(
                shouldFinishTransaction: false,
                shouldPersistSupport: false,
                purchaseResult: nil,
                shouldClearActivePurchase: false
            )
        }
    }

    private func clearPendingPurchase() {
        purchasingItem = nil
        purchaseCompletion = nil
    }
}

// MARK: - SKProductsRequestDelegate

extension SupportServiceImpl: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard !response.products.isEmpty else {
            loadProductsCompletion?(.failure(.emptyProducts))
            loadProductsCompletion = nil
            return
        }
        
        cacheProducts(response.products.map(StoreKitProduct.init(product:)))
        let items = products.map { $0.productItem() }
        loadProductsCompletion?(.success(items))
        loadProductsCompletion = nil
    }
    
    public func request(_ request: SKRequest, didFailWithError error: any Error) {
        loadProductsCompletion?(.failure(.general))
        loadProductsCompletion = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension SupportServiceImpl: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            handleTransaction(StoreKitTransaction(transaction: transaction))
        }
    }
}
