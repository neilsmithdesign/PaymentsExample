//
//  ExampleStore.swift
//  PaymentsExample
//
//  Created by Neil Smith on 29/11/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import Foundation
import Payments

protocol ExampleStoreObserving: AnyObject {
    func userCannotMakePayments(_ exampleStore: ExampleStore)
    func didLoadProducts(_ exampleStore: ExampleStore)
    func didRestorePurchase(_ exampleStore: ExampleStore)
    func didCompletePurchase(_ exampleStore: ExampleStore)
    func didDeferPayment(_ exampleStore: ExampleStore, with alert: AlertContent)
}

typealias AlertContent = PaymentDeferredAlert

final class ExampleStore {
    
    weak var observer: ExampleStoreObserving?
    
    init() {
        self.setupObservationOfPaymentEvents()
    }
    
    private lazy var configration: AppStoreConfiguration = {
        return AppStoreConfiguration(
            environment: .sandbox(simulateAskToBuy: false),
            receiptConfiguration: .appStore(validation: .local(self.receiptValidator), bundle: .main),
            productIdentifiers: Constants.productIdentifiers(for: .main)
        )
    }()

    private lazy var appStore: AppStore = {
        let appStore = AppStore(configuration: configration)
        appStore.observer = self
        return appStore
    }()
    
    
    private (set) var products: [Product] = []
    
    private var purchasedIdentfiers: Set<ProductIdentifier> = []
    
    private let receiptValidator: LocalReceiptValidator = {
        let input = LocalReceiptValidationInput(rootCertificateName: Constants.rootCertificateName, bundle: .main)
        return .init(input)
    }()
    
}


extension ExampleStore {
    
    func validateReceipt() {
        appStore.validateReceipt()
    }
    
    var isStoreAvailable: Bool {
        appStore.canMakePayments
    }
    
    func load() {
        if appStore.canMakePayments {
            appStore.loadProducts()
        } else {
            observer?.userCannotMakePayments(self)
        }
    }
    
    func restore() {
        guard isStoreAvailable else { return }
        appStore.restorePreviousPurchases()
    }
    
    func product(at indexPath: IndexPath) -> Product? {
        let r = indexPath.row
        guard r >= 0 && r < products.count else { return nil }
        return products[r]
    }
    
    func isPurchased(at indexPath: IndexPath) -> Bool {
        guard let product = self.product(at: indexPath) else { return false }
        return purchasedIdentfiers.contains(product.identifier)
    }
    
    func purchase(productAt indexPath: IndexPath) {
        guard isStoreAvailable else { return }  
        if let product = self.product(at: indexPath) {
            appStore.purchase(product)
        }
    }
    
}


// MARK: - Callbacks
extension ExampleStore: PaymentsObserving {
    
    private func setupObservationOfPaymentEvents() {
        appStore.add(observer: self, forPaymentEvent: .loadProductsSucceeded, selector: #selector(handleLoadProducts))
        appStore.add(observer: self, forPaymentEvent: .loadProductsFailed, selector: #selector(handleLoadProducts))
        appStore.add(observer: self, forPaymentEvent: .cannotMakePayments, selector: #selector(handleCannotMakePayments))
        appStore.add(observer: self, forPaymentEvent: .paymentCompletedSuccessfully, selector: #selector(handlePayment))
        appStore.add(observer: self, forPaymentEvent: .paymentFailed, selector: #selector(handlePayment))
        appStore.add(observer: self, forPaymentEvent: .paymentRestoredSuccessfully, selector: #selector(handlePayment))
        appStore.add(observer: self, forPaymentEvent: .paymentDeferred, selector: #selector(handlePayment))
    }
    
    
    // MARK: Notifications
    @objc private func handleLoadProducts(_ notification: Notification) {
        if let products = PaymentEvent.LoadProducts.Succeeded.init(notification)?.content {
            print("Successfully loaded products:")
            products.forEach { print($0.identifier) }
        } else if let error = PaymentEvent.LoadProducts.Failed.init(notification)?.content {
            print("Failed to load products: \(error.localizedDescription)")
        }
    }
    
    @objc private func handleCannotMakePayments(_ notification: Notification) {
        if let _ = PaymentEvent.CannotMakePayments.init(notification) {
            print("User cannot make payments")
        }
    }
    
    @objc private func handlePayment(_ notification: Notification) {
        if let id = PaymentEvent.Payment.Complete.init(notification)?.content {
            print("Successfully purchased product with identifier: \(id)")
        } else if let error = PaymentEvent.Payment.Failed.init(notification)?.content {
            print("Failed to purchased product with error: \(error.localizedDescription)")
        } else if let id = PaymentEvent.Payment.Restored.init(notification)?.content {
            print("Restored purchased product with identifier: \(id)")
        } else if let alert = PaymentEvent.Payment.Deferred.init(notification)?.content {
            print("Payment deferred for product with identifier: \(alert.productIdentifier)")
            print(alert.title)
            print(alert.message)
        }
    }
    
    
    // MARK: Observations
    func payments(_ payments: PaymentsProcessing, didValidate receipt: AppStoreReceipt) {
        for id in receipt.inAppPurchaseReceipts.map({ $0.id.product }) {
            self.purchasedIdentfiers.insert(id)
        }
        observer?.didRestorePurchase(self)
        // proceed with inspection of the receipt's properties and configure your app's features and content
        // for an in-app purchases contained in the receipt
    }
    
    func payments(_ payments: PaymentsProcessing, didLoad products: Set<Product>) {
        self.products = products.sorted(by: { $0.numericalPrice.doubleValue < $1.numericalPrice.doubleValue })
        observer?.didLoadProducts(self)
    }
    
    func payments(_ payments: PaymentsProcessing, didFailWith error: PaymentsError) {
        // Handle errors as per your app's logic
    }
    
    func payments(_ payments: PaymentsProcessing, paymentWasDeferred alert: PaymentDeferredAlert) {
        observer?.didDeferPayment(self, with: alert)
    }
    
    func payments(_ payments: PaymentsProcessing, didRestorePurchaseForProductWith identifier: ProductIdentifier) {
        self.purchasedIdentfiers.insert(identifier)
        observer?.didRestorePurchase(self)
    }
    
    func payments(_ payments: PaymentsProcessing, didCompletePurchaseForProductWith identifier: ProductIdentifier) {
        self.purchasedIdentfiers.insert(identifier)
        observer?.didCompletePurchase(self)
    }
    
    func userCannotMake(payments: PaymentsProcessing) {
        // Alert the user or configure your app appropriately
    }

    
}
