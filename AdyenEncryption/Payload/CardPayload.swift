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
    private var password: String?
    private var timestamp = ISO8601DateFormatter().string(from: Date())

    private enum CodingKeys: String, CodingKey {
        case number
        case holder = "holderName"
        case securityCode = "cvc"
        case expiryMonth
        case expiryYear
        case timestamp = "generationtime"
        case password
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

    internal func add(password: String?) -> Self {
        self.password = password
        return self
    }
}
