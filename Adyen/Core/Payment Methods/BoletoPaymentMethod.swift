//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An E-context Online payment method.
public struct BoletoPaymentMethod: PaymentMethod {

    /// :nodoc:
    public let type: String

    /// :nodoc:
    public let name: String

    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    /// :nodoc:
    public var displayInformation: DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: type)
    }

    /// :nodoc:
    public func localizedDisplayInformation(using _: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: type)
    }
}
