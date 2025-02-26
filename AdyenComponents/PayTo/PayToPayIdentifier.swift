//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Identifier options for PayTo, known as PayID.
internal enum PayToPayIdentifier: String, CustomStringConvertible, CaseIterable {
    case phone
    case email
    case abn
    case organizationId

    // TODO: Add translation
    public var description: String {
        switch self {
        case .phone:
            return "Phone"
        case .email:
            return "Email"
        case .abn:
            return "ABN"
        case .organizationId:
            return "Organization ID"
        }
    }
}

/// The payment options for PayTo component.
/// PayId contains 4 inner selection options.
internal enum PayToPaymentOption {
    
    /// Pay with PayId options (mobile, email etc)
    case payId(PayToPayIdentifier)
    
    /// Pay with BSB
    case BSB
}
