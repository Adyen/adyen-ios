//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// Identifier options for PayTo, known as PayID.
internal enum PayToPayIdentifier: String, CaseIterable {
    case phone
    case email
    case abn
    case organizationId

    internal var localizedKey: LocalizationKey {
        switch self {
        case .phone:
            return .paytoPayidOptionPhone
        case .email:
            return .paytoPayidOptionEmail
        case .abn:
            return LocalizationKey(key: "ABN")
        case .organizationId:
            return .paytoPayidLabelOrgid
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
