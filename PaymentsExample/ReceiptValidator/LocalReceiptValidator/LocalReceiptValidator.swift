//
//  LocalReceiptValidator.swift
//
//
//  Created by Neil Smith on 02/12/2019.
//

import Foundation
import Payments

public struct LocalReceiptValidator: ReceiptValidatingLocally {
    
    public init(_ input: LocalReceiptValidationInput) {
        self.input = input
    }
    
    private let input: LocalReceiptValidationInput
    
    public func validate(receipt data: Data) -> ReceiptValidationResult {
        let extraction = extractPKCS7Container(from: data)
        switch extraction {
        case .failure(let error): return .failure(.local(.extractionError(error)))
        case .success(let container):
        
            let verification = verifySignature(in: container, rootCertificate: input.rootCertificateName)
            switch verification {
            case .failure(let error): return .failure(.local(.signatureError(.verificationError(error))))
            case .success(let appleRootCertificate):
            
                let authentication = verifySignatureAuthenticity(in: container, against: appleRootCertificate)
                switch authentication {
                case .failure(let error): return .failure(.local(.signatureError(.authenticationError(error))))
                case .success:
                
                    let parseResult = parsedReceipt(from: container)
                    switch parseResult {
                    case .failure(let error): return .failure(.local(.parsingError(error)))
                    case .success(let receipt):
                    
                        let hashResult = validateHash(for: receipt)
                        switch hashResult {
                        case .failure(let error): return .failure(.local(error))
                        case .success(let receipt): return .success(receipt)
                        }
                    }
                }
            }
        }
    }
    
}

