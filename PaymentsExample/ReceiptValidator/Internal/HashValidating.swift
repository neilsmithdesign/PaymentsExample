//
//  HashValidating.swift
//  
//
//  Created by Neil Smith on 06/12/2019.
//

import UIKit
import Payments

typealias ValidatedHashResult = Result<AppStoreReceipt, LocalReceiptValidationError>

func validateHash(for receipt: AppStoreReceipt) -> ValidatedHashResult {
    
    guard
        let receiptOpaqueValueData = receipt.hash?.opaqueValue,
        let receiptBundleIdData = receipt.bundleID.data,
        let receiptHashData = receipt.hash?.sha1,
        let deviceIdentifierData = UIDevice.current.identifierData else {
            return .failure(.incorrectHash)
    }
    
    var computedHash = Array<UInt8>(repeating: 0, count: 20)
    
    var sha1Context = SHA_CTX()
    SHA1_Init(&sha1Context)
    SHA1_Update(&sha1Context, deviceIdentifierData.bytes, deviceIdentifierData.length)
    SHA1_Update(&sha1Context, receiptOpaqueValueData.bytes, receiptOpaqueValueData.length)
    SHA1_Update(&sha1Context, receiptBundleIdData.bytes, receiptBundleIdData.length)
    SHA1_Final(&computedHash, &sha1Context)
    
    let computedHashData = NSData(bytes: &computedHash, length: 20)
    guard computedHashData.isEqual(to: receiptHashData as Data) else {
        return .failure(.incorrectHash)
    }
    return .success(receipt)
    
}

