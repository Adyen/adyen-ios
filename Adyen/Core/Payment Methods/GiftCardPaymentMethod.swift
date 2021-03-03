//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct GiftCardPaymentMethod: PaymentMethod {

    internal let type: String

    internal let name: String

    internal let brand: String

    /// :nodoc:
    internal func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    /// :nodoc:
    internal var displayInformation: DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: brand)
    }

    /// :nodoc:
    internal func localizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: brand)
    }

}
