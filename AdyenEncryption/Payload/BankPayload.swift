//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct BankPayload: Payload {
    
    private var accountNumber: String?
    private var routingNumber: String?
    private let timestamp = ISO8601DateFormatter().string(from: Date())
    
    private enum CodingKeys: String, CodingKey {
        case accountNumber = "bankAccountNumber"
        case routingNumber = "bankLocationId"
        case timestamp = "generationtime"
    }
    
    internal func add(accountNumber: String) -> BankPayload {
        var payloadCopy = self
        payloadCopy.accountNumber = accountNumber
        return payloadCopy
    }
    
    internal func add(routingNumber: String) -> BankPayload {
        var payloadCopy = self
        payloadCopy.routingNumber = routingNumber
        return payloadCopy
    }
}
