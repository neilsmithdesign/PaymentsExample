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
    func didLoadProducts(_ exampleStore: ExampleStore)
    func didRestorePurchases(_ exampleStore: ExampleStore)
}

final class ExampleStore {
    
    weak var observer: ExampleStoreObserving?
    
    init() {
        self.payments.add(observer: self, forPaymentEvent: .loadProductsSucceeded, selector: #selector(didLoadProducts(_:)))
    }
        
    @objc private func didLoadProducts(_ notification: Notification) {
        guard let productIDs = PaymentEvent.LoadProducts.Succeeded.init(notification)?.content else { return }
        print(productIDs)
    }
    
    private lazy var payments: PaymentsProcessing = {
        let payments = AppStorePayments(configuration: paymentsConfigration)
        payments.observer = self
        return payments
    }()
    
    private lazy var paymentsConfigration: AppStoreConfiguration = {
        return AppStoreConfiguration(
            environment: .sandbox(simulateAskToBuy: false),
            receiptConfiguration: .appStore(validation: .local(self.receiptValidator), bundle: .main),
            productIdentifiers: Constants.productIdentifiers
        )
    }()
    
    var products: [Product] {
        return payments.availableProducts.sorted(by: { $0.numericalPrice.doubleValue < $1.numericalPrice.doubleValue })
    }
    
    private let receiptValidator: LocalReceiptValidator = {
        let input = LocalReceiptValidationInput(rootCertificateName: Constants.rootCertificateName, bundle: .main)
        return .init(input)
    }()
    
}

extension ExampleStore {
    
    func validateReceipt() {
        payments.verifyPurchases()
    }
    
    func load() {
        payments.loadProducts()
    }
    
    func restore() {
        payments.restorePreviousPurchases()
    }
    
    func purchase(productAt indexPath: IndexPath) {
        guard indexPath.row >= 0 && indexPath.row < products.count else { return }
        let product = products[indexPath.row]
        payments.purchase(product)
    }
    
}

extension ExampleStore: PaymentsObserving {
    
    func payments(_ payments: PaymentsProcessing, didValidate receipt: AppStoreReceipt) {
        print(receipt.bundleID.name)
    }
    
    func payments(_ payments: PaymentsProcessing, didLoad products: Set<Product>) {
        observer?.didLoadProducts(self)
    }
    
    func payments(_ payments: PaymentsProcessing, didFailWith error: PaymentsError) {
        switch error {
        case .productLoadRequestFailed(message: let msg): print(msg)
        default:
            print(error)
        }
    }
    
    func payments(_ payments: PaymentsProcessing, paymentWasDeferred alert: PaymentDeferredAlert) {
        
    }
    
    func didRestorePurchases(_ payments: PaymentsProcessing) {
        
    }
    
    func didCompletePurchase(_ payments: PaymentsProcessing) {
        
    }
    
    func userCannotMake(payments: PaymentsProcessing) {
        
    }
    
}
