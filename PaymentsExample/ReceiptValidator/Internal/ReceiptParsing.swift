//
//  ReceiptParsing.swift
//  
//
//  Created by Neil Smith on 05/12/2019.
//

import Foundation
import Payments

typealias ReceiptParsingResult = Result<AppStoreReceipt, ReceiptParsingError>

func parsedReceipt(from container: ReceiptContainer) -> ReceiptParsingResult {
    
    var bundleIdentifier: String?
    var bundleIdData: NSData?
    var appVersion: String?
    var opaqueValue: NSData?
    var sha1Hash: NSData?
    var inAppPurchaseReceipts = [InAppPurchaseReceipt]()
    var originalAppVersion: String?
    var receiptCreationDate: Date?
    var expirationDate: Date?
    
    guard let contents = container.pointee.d.sign.pointee.contents, let octets = contents.pointee.d.data else {
        return .failure(.malformed(.appReceipt))
    }
    
    var currentPayloadLocation = UnsafePointer(octets.pointee.data)
    let endOfPayload = currentPayloadLocation!.advanced(by: Int(octets.pointee.length))
    
    var type = Int32(0)
    var xclass = Int32(0)
    var length = 0
    
    ASN1_get_object(&currentPayloadLocation, &length, &type, &xclass,Int(octets.pointee.length))
    
    // Payload must be an ASN1 Set
    guard type == V_ASN1_SET else {
        return .failure(.malformed(.appReceipt))
    }
    
    // Decode Payload
    // Step through payload (ASN1 Set) and parse each ASN1 Sequence within (ASN1 Sets contain one or more ASN1 Sequences)
    while currentPayloadLocation! < endOfPayload {
        
        // Get next ASN1 Sequence
        ASN1_get_object(&currentPayloadLocation, &length, &type, &xclass, currentPayloadLocation!.distance(to: endOfPayload))
        
        // ASN1 Object type must be an ASN1 Sequence
        guard type == V_ASN1_SEQUENCE else {
            return .failure(.malformed(.appReceipt))
        }
        
        // Attribute type of ASN1 Sequence must be an Integer
        guard let attributeType = ASN1.decode(integerFrom: &currentPayloadLocation, length: currentPayloadLocation!.distance(to: endOfPayload)) else {
            return .failure(.malformed(.appReceipt))
        }
        
        // Attribute version of ASN1 Sequence must be an Integer
        guard ASN1.decode(integerFrom: &currentPayloadLocation, length: currentPayloadLocation!.distance(to: endOfPayload)) != nil else {
            return .failure(.malformed(.appReceipt))
        }
        
        // Get ASN1 Sequence value
        ASN1_get_object(&currentPayloadLocation, &length, &type, &xclass, currentPayloadLocation!.distance(to: endOfPayload))
        
        // ASN1 Sequence value must be an ASN1 Octet String
        guard type == V_ASN1_OCTET_STRING else {
            return .failure(.malformed(.appReceipt))
        }
        
        // Decode attributes
        switch attributeType {
        case 2:
            var startOfBundleId = currentPayloadLocation
            bundleIdData = NSData(bytes: startOfBundleId, length: length)
            bundleIdentifier = ASN1.decode(stringFrom: &startOfBundleId, length: length)
        case 3:
            var startOfAppVersion = currentPayloadLocation
            appVersion = ASN1.decode(stringFrom: &startOfAppVersion, length: length)
        case 4:
            let startOfOpaqueValue = currentPayloadLocation
            opaqueValue = NSData(bytes: startOfOpaqueValue, length: length)
        case 5:
            let startOfSha1Hash = currentPayloadLocation
            sha1Hash = NSData(bytes: startOfSha1Hash, length: length)
        case 17:
            var startOfInAppPurchaseReceipt = currentPayloadLocation
            let result = parsedInAppPurchaseReceipt(currentPayloadLocation: &startOfInAppPurchaseReceipt, payloadLength: length)
            switch result {
            case .success(let iapReceipt): inAppPurchaseReceipts.append(contentsOf: iapReceipt)
            case .failure: return .failure(.malformed(.inAppPurchaseReceipt))
            }
        case 12:
            var startOfReceiptCreationDate = currentPayloadLocation
            receiptCreationDate = ASN1.decode(dateFrom: &startOfReceiptCreationDate, length: length)
        case 19:
            var startOfOriginalAppVersion = currentPayloadLocation
            originalAppVersion = ASN1.decode(stringFrom: &startOfOriginalAppVersion, length: length)
        case 21:
            var startOfExpirationDate = currentPayloadLocation
            expirationDate = ASN1.decode(dateFrom: &startOfExpirationDate, length: length)
        default:
            break
        }
        
        currentPayloadLocation = currentPayloadLocation?.advanced(by: length)
    }

    guard
        let bundleID = bundleIdentifier,
        let current = appVersion,
        let original = originalAppVersion,
        let sha1 = sha1Hash,
        let opaque = opaqueValue,
        let creationDate = receiptCreationDate else {
            return .failure(.malformed(.inAppPurchaseReceipt))
    }
    
    let receipt = AppStoreReceipt(
        bundleID: .init(name: bundleID, data: bundleIdData),
        appVersion: .init(current: current, original: original),
        hash: .init(sha1: sha1, opaqueValue: opaque),
        date: .init(receiptCreation: creationDate, expiration: expirationDate),
        inAppPurchaseReceipts: inAppPurchaseReceipts
    )
    
    return .success(receipt)
    
}
