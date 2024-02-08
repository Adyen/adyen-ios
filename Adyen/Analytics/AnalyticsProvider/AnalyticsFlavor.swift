//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public enum AnalyticsFlavor {
    case components(type: PaymentMethodType)
    case dropIn(type: String = "dropin", paymentMethods: [String])

    // The `dropInComponent` type describes a component within the drop-in component.
    // In analytics, we need to distinguish when a component is used from the drop-in
    // and when it's used as standalone.
    case dropInComponent

    public var value: String {
        switch self {
        case .components:
            return "components"
        case .dropIn:
            return "dropin"
        case .dropInComponent:
            return "dropInComponent"
        }
    }
}
