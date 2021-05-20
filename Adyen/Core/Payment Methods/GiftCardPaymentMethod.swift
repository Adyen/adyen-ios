//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any Gift Card payment method.
public struct GiftCardPaymentMethod: PaymentMethod {

    /// :nodoc:
    public let type: String

    /// :nodoc:
    public let name: String

    /// :nodoc:
    public let brand: String

    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    /// :nodoc:
    public var displayInformation: DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: brand)
    }

    /// :nodoc:
    public func localizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: brand)
    }

    // MARK: - Decoding

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case brand
    }

}
