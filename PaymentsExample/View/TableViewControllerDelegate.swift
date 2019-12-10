//
//  TableViewControllerDelegate.swift
//  PaymentsExample
//
//  Created by Neil Smith on 09/12/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import Foundation

protocol TableViewControllerDelegate: AnyObject {
    func tableViewController(_ tableViewController: TableViewController, didSelectItemAt indexPath: IndexPath)
}
