//
//  SignatureVerification.swift
//  
//
//  Created by Neil Smith on 05/12/2019.
//

import Foundation
import Payments

typealias AppleRootCertificate = UnsafeMutablePointer<X509>
typealias SignatureVerificationResult = Result<AppleRootCertificate, ReceiptSignatureVerificationError>

func verifySignature(in container: ReceiptContainer, rootCertificate name: String) -> SignatureVerificationResult {
    let pkcs7SignedTypeCode = OBJ_obj2nid(container.pointee.type)
    guard pkcs7SignedTypeCode == NID_pkcs7_signed else {
        return .failure(.notSigned)
    }
    let signatureResult = load(rootCertificateWith: name)
    return signatureResult
}


private func load(rootCertificateWith name: String) -> SignatureVerificationResult {
    guard
        let url = Bundle.main.url(forResource: name, withExtension: "cer"),
        let data = try? Data(contentsOf: url) else {
            return .failure(.rootCertificateNotFound)
    }
    let certificateBIO = BIO_new(BIO_s_mem())
    BIO_write(certificateBIO, (data as NSData).bytes, Int32(data.count))
    guard let certificateX509 = d2i_X509_bio(certificateBIO, nil) else {
        return .failure(.rootCertificateNotFound)
    }
    return .success(certificateX509)
}
