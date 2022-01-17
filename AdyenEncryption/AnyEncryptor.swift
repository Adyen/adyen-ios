//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol AnyEncryptor {}

extension AnyEncryptor {
    
    /// Helper function to encrypt a payload data with JWE.
    static func encrypt(_ payload: Payload, with publicKey: String) throws -> String {
        let tokens = publicKey.components(separatedBy: "|")
        guard tokens.count == 2 else { throw EncryptionError.invalidKey }
        let secKey = try createSecKey(fromModulus: tokens[1], exponent: tokens[0])
        return try JSONWebEncryptionGenerator()
            .generate(withPayload: payload.jsonData(),
                      publicRSAKey: secKey,
                      header: .defaultHeader).compactRepresentation
    }
}
