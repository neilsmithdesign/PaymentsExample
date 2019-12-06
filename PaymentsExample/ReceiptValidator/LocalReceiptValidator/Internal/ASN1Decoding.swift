//
//  ASN1Decoding.swift
//  
//
//  Created by Neil Smith on 05/12/2019.
//

import Foundation

struct ASN1 {
    
    static func decode(integerFrom pointer: inout UnsafePointer<UInt8>?, length: Int) -> Int? {
        var type = Int32(0)
        var xclass = Int32(0)
        var intLength = 0
        
        ASN1_get_object(&pointer, &intLength, &type, &xclass, length)
        
        guard type == V_ASN1_INTEGER else { return nil }
        
        let integer = c2i_ASN1_INTEGER(nil, &pointer, intLength)
        let result = ASN1_INTEGER_get(integer)
        ASN1_INTEGER_free(integer)
        
        return result
    }
    
    static func decode(stringFrom pointer: inout UnsafePointer<UInt8>?, length: Int) -> String? {
        var type = Int32(0)
        var xclass = Int32(0)
        var stringLength = 0
        
        ASN1_get_object(&pointer, &stringLength, &type, &xclass, length)
        
        if type == V_ASN1_UTF8STRING {
            let mutableStringPointer = UnsafeMutableRawPointer(mutating: pointer!)
            return String(bytesNoCopy: mutableStringPointer, length: stringLength, encoding: .utf8, freeWhenDone: false)
        }
        
        if type == V_ASN1_IA5STRING {
            let mutableStringPointer = UnsafeMutableRawPointer(mutating: pointer!)
            return String(bytesNoCopy: mutableStringPointer, length: stringLength, encoding: .ascii, freeWhenDone: false)
        }
        
        return nil
    }
    
    static func decode(dateFrom pointer: inout UnsafePointer<UInt8>?, length: Int) -> Date? {
        fatalError()
    }
    
}

