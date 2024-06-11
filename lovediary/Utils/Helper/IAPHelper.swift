//
//  IAPHelper.swift
//  lovediary
//
//  Created by daovu on 22/03/2021.
//

import Foundation
import StoreKit
import Combine
import Configuration

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

class IAPHelper: NSObject {
    
    static let shared: IAPHelper = IAPHelper()
    
    private let productIdentifiers: Set<ProductIdentifier>
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    var productRemoveAds: SKProduct?
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
    
    static func formatPrice(from product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? ""
    }
    
    func configure() {
        if !Settings.isRemoveAds.value {
            SKPaymentQueue.default().add(self)
            requestProducts()
        }
    }
    
    private override init() {
        productIdentifiers = [AppConfigs.adsProductIdentifier]
        super.init()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
}

// MARK: - StoreKit API

extension IAPHelper {
    
    func requestAdsProductInfo() -> AnyPublisher<SKProduct, Never> {
        ProgressHelper.shared.show()
        return Deferred {
            Future { promise in
                self.requestProducts { success, resproducts in
                    ProgressHelper.shared.hide()
                    if success,
                       let products = resproducts,
                       let product = products.first(where: { $0.productIdentifier == AppConfigs.adsProductIdentifier }) {
                        promise(.success(product))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func requestProducts(completionHandler: ProductsRequestCompletionHandler? = nil) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    func buyProduct(_ product: SKProduct) {
        print("buying...")
        ProgressHelper.shared.show()
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func restorePurchases() {
        print("restore...")
        ProgressHelper.shared.show(isShowCancelButton: true)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        print("Loaded list of products...")
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
        
        guard products.count != 0 else { return }
        for product in products where product.productIdentifier == AppConfigs.adsProductIdentifier {
            productRemoveAds = product
            break
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
            case .failed:
                fail(transaction: transaction)
            case .restored:
                restore(transaction: transaction)
            case .deferred:
                break
            case .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        deliverPurchaseNotificationFor(completed: false)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        ProgressHelper.shared.hide()
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        deliverPurchaseNotificationFor(completed: true)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(completed: true)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print("Transaction Error: \(transaction.error?.localizedDescription ?? "error transaction")")
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
        deliverPurchaseNotificationFor(completed: false)
    }
    
    private func deliverPurchaseNotificationFor(completed: Bool) {
        Settings.isRemoveAds.value = completed
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: completed)
        ProgressHelper.shared.hide()
    }
}

