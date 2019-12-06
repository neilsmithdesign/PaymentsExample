//
//  ContainerExtraction.swift
//  
//
//  Created by Neil Smith on 05/12/2019.
//

import Foundation
import Payments

typealias ReceiptContainer = UnsafeMutablePointer<PKCS7>
typealias ReceiptContainerExtractionResult = Result<ReceiptContainer, ReceiptContainerExtractionError>

func extractPKCS7Container(from receiptData: Data) -> ReceiptContainerExtractionResult {
    
    let receiptBIO = BIO_new(BIO_s_mem())
    BIO_write(receiptBIO, (receiptData as NSData).bytes, Int32(receiptData.count))
    let pkcs7Container = d2i_PKCS7_bio(receiptBIO, nil)
    guard pkcs7Container != nil else {
        return .failure(.emptyContents)
    }
    let pkcs7DataTypeCode = OBJ_obj2nid(pkcs7_d_sign(pkcs7Container).pointee.contents.pointee.type)
    guard pkcs7DataTypeCode == NID_pkcs7_data else {
        return .failure(.emptyContents)
    }
    guard let container = pkcs7Container else {
        return .failure(.emptyContents)
    }
    return .success(container)
    
}
