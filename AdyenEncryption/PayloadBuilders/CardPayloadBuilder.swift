//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the information of a card that is yet to be encrypted.
internal class CardPayloadBuilder {

    internal var payload = CardPayload()

    @discardableResult
    internal func add(number: String) -> Payload {
        payload.number = number
        return payload
    }

    @discardableResult
    internal func add(securityCode: String) -> Payload {
        payload.securityCode = securityCode
        return payload
    }

    @discardableResult
    internal func add(expiryMonth: String) -> Payload {
        payload.expiryMonth = expiryMonth
        return payload
    }

    @discardableResult
    internal func add(expiryYear: String) -> Payload {
        payload.expiryYear = expiryYear
        return payload
    }
    
    internal struct CardPayload: Payload {

        /// The card number.
        internal var number: String?
        internal var securityCode: String?
        internal var expiryMonth: String?
        internal var expiryYear: String?
        internal var holder: String?

        private enum CodingKeys: String, CodingKey {
            case number
            case holder = "holderName"
            case securityCode = "cvc"
            case expiryMonth
            case expiryYear
            case generationDate = "generationtime"
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
            try container.encode(timestampString, forKey: .generationDate)
        }
    }

}
