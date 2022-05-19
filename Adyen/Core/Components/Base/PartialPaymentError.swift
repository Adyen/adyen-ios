//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Indicates a partial payment related errors.
public enum PartialPaymentError: LocalizedError {

    /// Indicates that there is zero remaining amount to be paid.
    case zeroRemainingAmount

    /// Indicates that the order data is missing where its required.
    case missingOrderData
    
    /// Indicates that the partial payment flow is not supported with the current component.
    case notSupportedForComponent

    public var errorDescription: String? {
        switch self {
        case .zeroRemainingAmount:
            return "There is no remaining amount to be paid."
        case .missingOrderData:
            return "Order data is missing"
        case .notSupportedForComponent:
            return "Partial payment flow is not supported with the current component."
        }
    }
}
