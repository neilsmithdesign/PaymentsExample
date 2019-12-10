//
//  SignatureAuthentication.swift
//  
//
//  Created by Neil Smith on 05/12/2019.
//

import Foundation
import Payments

typealias AuthenticatedSignature = AppleRootCertificate
typealias SignatureAuthenticationResult = Result<AuthenticatedSignature, ReceiptSignatureAuthenticationError>

func verifySignatureAuthenticity(in container: ReceiptContainer, against rootCertificate: AppleRootCertificate) -> SignatureAuthenticationResult {
    let certificateStore = X509_STORE_new()
    X509_STORE_add_cert(certificateStore, rootCertificate)
    OpenSSL_add_all_digests()
    let result = PKCS7_verify(container, nil, certificateStore, nil, nil, 0)
    switch result {
    case 1: return .success(rootCertificate)
    default: return .failure(.invalid)
    }
    
}
