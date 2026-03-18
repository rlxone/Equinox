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

@testable import EquinoxCore
import StoreKit
import XCTest

final class SupportServiceTests: XCTestCase {
    private var storageCore: StorageCore!
    private var userDefaults: MockUserDefaults!
    private var paymentQueue: MockSupportPaymentQueue!
    private var supportService: SupportServiceImpl!

    override func setUpWithError() throws {
        userDefaults = MockUserDefaults()
        storageCore = StorageCoreImpl(userDefaults: userDefaults)
        paymentQueue = MockSupportPaymentQueue()
        supportService = SupportServiceImpl(storageCore: storageCore, paymentQueue: paymentQueue)
    }

    override func tearDownWithError() throws {
        supportService = nil
        paymentQueue = nil
        storageCore = nil
        userDefaults = nil
    }

    func testInitRegistersPaymentObserver() {
        XCTAssertEqual(paymentQueue.addedObserverIdentifiers.count, 1)
        XCTAssertEqual(paymentQueue.addedObserverIdentifiers.first, ObjectIdentifier(supportService))
    }

    func testDeinitRemovesPaymentObserver() {
        let queue = MockSupportPaymentQueue()
        let storageCore = StorageCoreImpl(userDefaults: MockUserDefaults())
        var service: SupportServiceImpl? = SupportServiceImpl(storageCore: storageCore, paymentQueue: queue)
        let serviceIdentifier = service.map(ObjectIdentifier.init)

        service = nil

        XCTAssertEqual(queue.removedObserverIdentifiers.count, 1)
        XCTAssertEqual(queue.removedObserverIdentifiers.first, serviceIdentifier)
    }

    func testPurchaseEnqueuesPaymentForCachedProduct() {
        let product = MockSupportStoreProduct(id: SupportProductIdentifier.supportTier1.rawValue)
        supportService.cacheProducts([product])

        supportService.purchase(item: product.productItem()) { _ in }

        XCTAssertEqual(paymentQueue.addedPaymentIdentifiers, [product.productIdentifier])
        XCTAssertTrue(supportService.hasPendingPurchase)
    }

    func testPurchasedSupportTransactionWithoutPendingPurchasePersistsSupportState() {
        let transaction = MockSupportTransaction(
            productIdentifier: SupportProductIdentifier.supportTier1.rawValue,
            state: .purchased
        )

        supportService.handleTransaction(transaction)

        XCTAssertTrue(supportService.isSupported)
        XCTAssertEqual(paymentQueue.finishedTransactionIdentifiers, [transaction.productIdentifier])
        XCTAssertFalse(supportService.hasPendingPurchase)
    }

    func testRestoredSupportTransactionPersistsSupportState() {
        let transaction = MockSupportTransaction(
            productIdentifier: SupportProductIdentifier.supportTier2.rawValue,
            state: .restored
        )

        supportService.handleTransaction(transaction)

        XCTAssertTrue(supportService.isSupported)
        XCTAssertEqual(paymentQueue.finishedTransactionIdentifiers, [transaction.productIdentifier])
    }

    func testPurchasedMatchingPendingPurchasePersistsSupportStateAndCompletesPurchase() {
        let product = MockSupportStoreProduct(id: SupportProductIdentifier.supportTier3.rawValue)
        supportService.cacheProducts([product])

        var purchasedItem: ProductItem?
        supportService.purchase(item: product.productItem()) { result in
            if case .success(let item) = result {
                purchasedItem = item
            }
        }

        supportService.handleTransaction(
            MockSupportTransaction(productIdentifier: product.productIdentifier, state: .purchased)
        )

        XCTAssertTrue(supportService.isSupported)
        XCTAssertEqual(purchasedItem?.id, product.productIdentifier)
        XCTAssertEqual(paymentQueue.finishedTransactionIdentifiers.last, product.productIdentifier)
        XCTAssertFalse(supportService.hasPendingPurchase)
    }

    func testFailedMatchingPendingPurchaseReportsFailureWithoutPersistingSupportState() {
        let product = MockSupportStoreProduct(id: SupportProductIdentifier.supportTier4.rawValue)
        supportService.cacheProducts([product])

        var purchaseError: StoreError?
        supportService.purchase(item: product.productItem()) { result in
            if case .failure(let error) = result {
                purchaseError = error
            }
        }

        supportService.handleTransaction(
            MockSupportTransaction(productIdentifier: product.productIdentifier, state: .failed)
        )

        XCTAssertFalse(supportService.isSupported)
        if case .failedPurchase? = purchaseError {
            XCTAssertTrue(true)
        } else {
            XCTFail("Expected failedPurchase error")
        }
        XCTAssertEqual(paymentQueue.finishedTransactionIdentifiers.last, product.productIdentifier)
        XCTAssertFalse(supportService.hasPendingPurchase)
    }

    func testNonSupportPurchaseDoesNotPersistSupportState() {
        let transaction = MockSupportTransaction(
            productIdentifier: "com.rlxone.equinox.other",
            state: .purchased
        )

        supportService.handleTransaction(transaction)

        XCTAssertFalse(supportService.isSupported)
        XCTAssertEqual(paymentQueue.finishedTransactionIdentifiers, [transaction.productIdentifier])
    }
}

private final class MockSupportPaymentQueue: SupportPaymentQueue {
    private(set) var addedObserverIdentifiers = [ObjectIdentifier]()
    private(set) var removedObserverIdentifiers = [ObjectIdentifier]()
    private(set) var addedPaymentIdentifiers = [String]()
    private(set) var finishedTransactionIdentifiers = [String]()

    func add(_ observer: SKPaymentTransactionObserver) {
        addedObserverIdentifiers.append(ObjectIdentifier(observer as AnyObject))
    }

    func remove(_ observer: SKPaymentTransactionObserver) {
        removedObserverIdentifiers.append(ObjectIdentifier(observer as AnyObject))
    }

    func add(_ payment: SKPayment) {
        addedPaymentIdentifiers.append(payment.productIdentifier)
    }

    func finishTransaction(_ transaction: SupportTransaction) {
        finishedTransactionIdentifiers.append(transaction.productIdentifier)
    }
}

private struct MockSupportStoreProduct: SupportStoreProduct {
    let id: String

    var productIdentifier: String {
        return id
    }

    var priceValue: Decimal {
        return 1
    }

    func productItem() -> ProductItem {
        return ProductItem(id: id, title: "Support", price: "$0.99")
    }

    func payment() -> SKPayment {
        let payment = SKMutablePayment()
        payment.setValue(id, forKey: "productIdentifier")
        return payment
    }
}

private final class MockSupportTransaction: SupportTransaction {
    let productIdentifier: String
    let state: SupportTransactionState

    init(productIdentifier: String, state: SupportTransactionState) {
        self.productIdentifier = productIdentifier
        self.state = state
    }
}
