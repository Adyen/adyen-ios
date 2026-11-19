//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The plain-text JSON of a single encrypted field: `{ "<field key>": value, "generationtime": <ISO 8601 date> }`.
internal struct FieldPayload: Payload {

    private let field: CheckoutEncryptor.Field
    private let value: String
    private let timestamp: Date

    internal init(field: CheckoutEncryptor.Field, value: String, timestamp: Date = Date()) {
        self.field = field
        self.value = value
        self.timestamp = timestamp
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(value, forKey: Key(field.key))
        try container.encode(timestamp.ISO8601Format(), forKey: Key("generationtime"))
    }

    private struct Key: CodingKey {
        internal let stringValue: String
        internal var intValue: Int? {
            nil
        }

        internal init(_ stringValue: String) {
            self.stringValue = stringValue
        }

        internal init?(stringValue: String) {
            self.init(stringValue)
        }

        internal init?(intValue: Int) {
            nil
        }
    }
}
