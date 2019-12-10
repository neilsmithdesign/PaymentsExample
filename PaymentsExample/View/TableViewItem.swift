//
//  TableViewItem.swift
//  PaymentsExample
//
//  Created by Neil Smith on 09/12/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import Foundation
import Payments

struct TableViewItem {
    let title: String
    let detail: String
}

extension TableViewItem {
    init(product: Product, isPurchased: Bool) {
        self.title = product.title
        if isPurchased {
            self.detail = "Purchased"
        } else {
            self.detail = product.price
        }
    }
}
