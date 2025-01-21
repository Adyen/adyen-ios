//
//  JSONEncoder+Extensions.swift
//  AdyenEncryption
//
//  Created by Naufal Aros on 20/01/2025.
//  Copyright © 2025 Adyen. All rights reserved.
//

import Foundation

extension JSONEncoder {
    internal static func encodeWithSortedKeys(_ encodable: Encodable) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys

        return try encoder.encode(encodable)
    }
}
