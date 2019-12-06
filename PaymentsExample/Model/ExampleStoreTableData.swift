//
//  ExampleStoreTableData.swift
//  PaymentsExample
//
//  Created by Neil Smith on 05/12/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import Foundation

enum ExampleStoreTableData {
    
    case product(String, String)
    
    var item: TableViewItem {
        switch self {
        case .product(let title, let detail): return .init(title: title, detail: detail)
        }
    }
}

