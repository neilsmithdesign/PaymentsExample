//
//  TableViewControllerDataSource.swift
//  PaymentsExample
//
//  Created by Neil Smith on 09/12/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import Foundation

protocol TableViewControllerDataSource: AnyObject {
    func numberOfSections(_ tableViewController: TableViewController) -> Int
    func numberOfItems(in section: Int, tableViewController: TableViewController) -> Int
    func tableViewController(_ tableViewController: TableViewController, itemAt indexPath: IndexPath) -> TableViewItem?
}
