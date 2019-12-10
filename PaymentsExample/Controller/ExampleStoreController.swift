//
//  ExampleStoreController.swift
//  PaymentsExample
//
//  Created by Neil Smith on 29/11/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import UIKit

final class ExampleStoreController {
    
    
    // MARK: Interface
    init(window: UIWindow) {
        self.model = ExampleStore()
        window.rootViewController = self.navigationController
        window.makeKeyAndVisible()
        self.model.observer = self
        self.model.validateReceipt()
        self.model.load()
    }
    
    
    // Model
    private let model: ExampleStore
    
    // View
    private lazy var navigationController: UINavigationController = .init(rootViewController: self.viewController)
    
    private lazy var viewController: TableViewController = {
        let tvc = TableViewController()
        tvc.navigationItem.title = "Payments Example"
        tvc.dataSource = self
        tvc.delegate = self
        if model.isStoreAvailable {
            tvc.navigationItem.rightBarButtonItem = self.restoreButton
        } else {
            tvc.navigationItem.rightBarButtonItem = nil
        }
        return tvc
    }()
    
    
    private lazy var restoreButton: UIBarButtonItem = {
        let bbi = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(didTapRestore))
        return bbi
    }()
    
}


// MARK: - Target-action
extension ExampleStoreController {
    
    @objc private func didTapRestore() {
        model.restore()
    }
    
}


// MARK: - Data source
extension ExampleStoreController: TableViewControllerDataSource {
    
    func numberOfSections(_ tableViewController: TableViewController) -> Int {
        1
    }
    
    func numberOfItems(in section: Int, tableViewController: TableViewController) -> Int {
        return model.isStoreAvailable ? model.products.count : 1
    }
    
    func tableViewController(_ tableViewController: TableViewController, itemAt indexPath: IndexPath) -> TableViewItem? {
        if model.isStoreAvailable {
            guard let product = model.product(at: indexPath) else { return nil }
            return TableViewItem(product: product, isPurchased: model.isPurchased(at: indexPath))
        } else {
            return TableViewItem(title: "Store Unavailable", detail: " ")
        }
    }
    
}


// MARK: - Delegate
extension ExampleStoreController: TableViewControllerDelegate {
    
    func tableViewController(_ tableViewController: TableViewController, didSelectItemAt indexPath: IndexPath) {
        model.purchase(productAt: indexPath)
    }
    
}


// MARK: - Model observations
extension ExampleStoreController: ExampleStoreObserving {
    
    func userCannotMakePayments(_ exampleStore: ExampleStore) {
        viewController.reload()
        viewController.navigationItem.rightBarButtonItem = nil
    }

    func didDeferPayment(_ exampleStore: ExampleStore, with alert: AlertContent) {
        let alert = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        navigationController.present(alert, animated: true)
    }

    func didCompletePurchase(_ exampleStore: ExampleStore) {
        viewController.reload()
    }
    
    func didLoadProducts(_ exampleStore: ExampleStore) {
        viewController.reload()
    }
    
    func didRestorePurchase(_ exampleStore: ExampleStore) {
        viewController.reload()
    }
    
}
