//
//  File.swift
//  
//
//  Created by Neil Smith on 06/12/2019.
//

import UIKit

extension UIDevice {
    
    var identifierData: NSData? {
        var uuid = identifierForVendor?.uuid
        let pointer = withUnsafePointer(to: &uuid) { UnsafeRawPointer($0) }
        return NSData(bytes: pointer, length: 16)
    }
    
}
