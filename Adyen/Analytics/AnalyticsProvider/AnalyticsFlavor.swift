//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public enum AnalyticsFlavor {
    case components(type: PaymentMethodType)
    case dropIn(type: String = "dropin", paymentMethods: [String])

    public var value: String {
        switch self {
        case .components:
            return "components"
        case .dropIn:
            return "dropin"
        }
    }
}
