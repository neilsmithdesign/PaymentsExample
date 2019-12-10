//
//  Constants.swift
//  PaymentsExample
//
//  Created by Neil Smith on 06/12/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import Foundation
import Payments

enum Constants {
    static let rootCertificateName = "AppleIncRootCertificate"
    static func productIdentifiers(for bundle: Bundle) -> Set<ProductIdentifier> {
        guard let id = bundle.bundleIdentifier else { return [] }
        return [
            id + ".consumable",
            id + ".non.consumable",
            id + ".auto.renewable.subscription",
            id + ".non.renewing.subscription"
        ]
    }
}


//
//final class Test {
//    
//    init() {
//        
//        /// Declare your remote URL for receipt validation
//        let url = URL(string: "YOUR_SERVER_RECEIPT_VALIDATION_END_POINT")!
//        
//        /// Create a configuration (more parameters available, see here)
//        let config = AppStoreConfiguration(
//            environment: .production,
//            receiptConfiguration: .appStore(validation: .remote(url), bundle: .main),
//            productIdentifiers: ["YOUR_PRODUCT_IDENTIFIERS"]
//        )
//        
//        /// Assign it to an AppStore instance
//        let appStore = AppStore(configuration: config)
//        
//        /// Set an observer to receive updates
//        appStore.observer = self
//        
//    
//        
//    }
//    
//}
