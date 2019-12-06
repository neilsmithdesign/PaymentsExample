//
//  ExampleStoreController.swift
//  PaymentsExample
//
//  Created by Neil Smith on 29/11/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import UIKit

final class ExampleStoreController {
    
    init(window: UIWindow) {
        let model = ExampleStore()
        self.model = model
        window.rootViewController = self.navigationController
        window.makeKeyAndVisible()
        model.observer = self
        model.load()
    }
    
    private let model: ExampleStore
    
    var tableData: [[ExampleStoreTableData]] {
        let productData = model.products.map { ExampleStoreTableData.product($0.title, $0.price) }
        return [productData]
    }
    
    
    private lazy var navigationController: UINavigationController = {
        let nc = UINavigationController(rootViewController: self.viewController)
        return nc
    }()
    
    
    private lazy var viewController: TableViewController = {
        let tvc = TableViewController()
        tvc.navigationItem.title = "Payments Example"
        tvc.navigationItem.rightBarButtonItem = self.restoreButton
        tvc.dataSource = self
        return tvc
    }()
    
    private lazy var restoreButton: UIBarButtonItem = {
        let bbi = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(didTapRestore))
        return bbi
    }()
    
    @objc private func didTapRestore() {
        model.restore()
    }
    
}

extension ExampleStoreController: TableViewControllerDataSource {
    
    func numberOfSections(_ tableViewController: TableViewController) -> Int {
        return tableData.count
    }
    
    func numberOfItems(in section: Int, tableViewController: TableViewController) -> Int {
        return tableData[section].count
    }
    
    func tableViewController(_ tableViewController: TableViewController, itemAt indexPath: IndexPath) -> TableViewItem? {
        return tableData[indexPath.section][indexPath.row].item
    }
    
}

extension ExampleStoreController: TableViewControllerDelegate {
    
    func tableViewController(_ tableViewController: TableViewController, didSelectItemAt indexPath: IndexPath) {
        model.purchase(productAt: indexPath)
    }
    
}


extension ExampleStoreController: ExampleStoreObserving {
    
    func didLoadProducts(_ exampleStore: ExampleStore) {
        viewController.reload()
    }
    
    func didRestorePurchases(_ exampleStore: ExampleStore) {
        viewController.reload()
    }
    
}
