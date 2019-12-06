//
//  InAppReceiptParsing.swift
//  
//
//  Created by Neil Smith on 05/12/2019.
//

import Foundation
import Payments

typealias InAppPurchaseReceiptParsingResult = Result<InAppPurchaseReceipt, ReceiptParsingError>

func parsedInAppPurchaseReceipt(currentPayloadLocation: inout PayloadLocation?, payloadLength: Int) -> InAppPurchaseReceiptParsingResult {
    
    var quantity: Int?
    var productId: String?
    var transactionId: String?
    var originalTransactionId: String?
    var purchaseDate: Date?
    var originalPurchaseDate: Date?
//    var subscriptionExpirationDate: Date?
//    var cancellationDate: Date?
    var webOrderLineItemId: Int?
    
    let endOfPayload = currentPayloadLocation!.advanced(by: payloadLength)
    var type = Int32(0)
    var xclass = Int32(0)
    var length = 0
    
    ASN1_get_object(&currentPayloadLocation, &length, &type, &xclass, payloadLength)
    
    // Payload must be an ASN1 Set
    guard type == V_ASN1_SET else {
        return .failure(.malformed(.inAppPurchaseReceipt))
    }
    
    // Decode Payload
    // Step through payload (ASN1 Set) and parse each ASN1 Sequence within (ASN1 Sets contain one or more ASN1 Sequences)
    while currentPayloadLocation! < endOfPayload {
        
        // Get next ASN1 Sequence
        ASN1_get_object(&currentPayloadLocation, &length, &type, &xclass, currentPayloadLocation!.distance(to: endOfPayload))
        
        // ASN1 Object type must be an ASN1 Sequence
        guard type == V_ASN1_SEQUENCE else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        // Attribute type of ASN1 Sequence must be an Integer
        guard let attributeTypeValue = ASN1.decode(integerFrom: &currentPayloadLocation, length: currentPayloadLocation!.distance(to: endOfPayload)) else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        // Attribute version of ASN1 Sequence must be an Integer
        guard ASN1.decode(integerFrom: &currentPayloadLocation, length: currentPayloadLocation!.distance(to: endOfPayload)) != nil else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        // Get ASN1 Sequence value
        ASN1_get_object(&currentPayloadLocation, &length, &type, &xclass, currentPayloadLocation!.distance(to: endOfPayload))
        
        // ASN1 Sequence value must be an ASN1 Octet String
        guard type == V_ASN1_OCTET_STRING else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        guard let attribute = InAppPurchaseReceipt.Keys.init(asn1Field: attributeTypeValue) else {
            return .failure(.malformed(.inAppPurchaseReceipt))
        }
        
        // Decode attributes
        switch attribute {
        case .quantity:
            var startOfQuantity = currentPayloadLocation
            quantity = ASN1.decode(integerFrom: &startOfQuantity, length: length)
        case .productIdentifier:
            var startOfProductId = currentPayloadLocation
            productId = ASN1.decode(stringFrom: &startOfProductId, length: length)
        case .transactionIdentifier:
            var startOfTransactionId = currentPayloadLocation
            transactionId = ASN1.decode(stringFrom: &startOfTransactionId, length: length)
        case .originalTransactionIdentifier:
            var startOfOriginalTransactionId = currentPayloadLocation
            originalTransactionId = ASN1.decode(stringFrom: &startOfOriginalTransactionId, length: length)
        case .purchaseDate:
            var startOfPurchaseDate = currentPayloadLocation
            purchaseDate = ASN1.decode(dateFrom: &startOfPurchaseDate, length: length)
        case .originalPurchaseDate:
            var startOfOriginalPurchaseDate = currentPayloadLocation
            originalPurchaseDate = ASN1.decode(dateFrom: &startOfOriginalPurchaseDate, length: length)
//        case .subscriptionExpirationDate:
//            var startOfSubscriptionExpirationDate = currentPayloadLocation
//            subscriptionExpirationDate = ASN1.decode(dateFrom: &startOfSubscriptionExpirationDate, length: length)
//        case .cancellationDate:
//            var startOfCancellationDate = currentPayloadLocation
//            cancellationDate = ASN1.decode(dateFrom: &startOfCancellationDate, length: length)
        case .webOrderLineItem:
            var startOfWebOrderLineItemId = currentPayloadLocation
            webOrderLineItemId = ASN1.decode(integerFrom: &startOfWebOrderLineItemId, length: length)
        default:
            break
        }
        
        currentPayloadLocation = currentPayloadLocation!.advanced(by: length)
    }
    
    guard
        let q = quantity,
        let ids = InAppPurchaseReceipt.IDs(
            product: productId,
            transaction: transactionId,
            originalTransaction: originalTransactionId,
            webOrderLineItem: webOrderLineItemId,
            appItem: nil,
            externalVersion: nil
        ),
        let pd = purchaseDate,
        let opd = originalPurchaseDate
        else {
            return .failure(.malformed(.inAppPurchaseReceipt))
    }
    
    let receipt = InAppPurchaseReceipt(
        quantity: q,
        id: ids,
        purchaseDate: pd,
        originalPurchaseDate: opd,
        subscription: nil
    )
    
    return .success(receipt)
    
}

