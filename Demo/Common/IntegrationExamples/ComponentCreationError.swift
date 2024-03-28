//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenComponents
import Foundation

public enum IntegrationError: LocalizedError {
    
    case paymentMethodNotAvailable(paymentMethod: PaymentMethod.Type)
    
    public var errorDescription: String? {
        switch self {
        case let .paymentMethodNotAvailable(paymentMethodType):
            return "\(String(describing: paymentMethodType)) is not available in payment methods response."
        }
    }
}
