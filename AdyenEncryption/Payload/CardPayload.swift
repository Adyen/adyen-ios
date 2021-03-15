//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the information of a card that is yet to be encrypted.
internal class CardPayload: Payload {

    private var number: String?
    private var securityCode: String?
    private var expiryMonth: String?
    private var expiryYear: String?
    private var holder: String?

    private enum CodingKeys: String, CodingKey {
        case number
        case holder = "holderName"
        case securityCode = "cvc"
        case expiryMonth
        case expiryYear
        case timestamp = "generationtime"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let number = number {
            try container.encode(number, forKey: .number)
        }
        if let holder = holder {
            try container.encode(holder, forKey: .holder)
        }
        if let securityCode = securityCode {
            try container.encode(securityCode, forKey: .securityCode)
        }
        if let expiryMonth = expiryMonth {
            try container.encode(expiryMonth, forKey: .expiryMonth)
        }
        if let expiryYear = expiryYear {
            try container.encode(expiryYear, forKey: .expiryYear)
        }

        let timestampString = ISO8601DateFormatter().string(from: Date())
        try container.encode(timestampString, forKey: .timestamp)
    }

    internal func add(number: String?) -> Self {
        self.number = number
        return self
    }

    internal func add(securityCode: String?) -> Self {
        self.securityCode = securityCode
        return self
    }

    internal func add(expiryMonth: String?) -> Self {
        self.expiryMonth = expiryMonth
        return self
    }

    internal func add(expiryYear: String?) -> Self {
        self.expiryYear = expiryYear
        return self
    }

    internal func add(holder: String?) -> Self {
        self.holder = holder
        return self
    }
}
