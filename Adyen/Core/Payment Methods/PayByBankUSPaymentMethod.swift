//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// PayByBank US payment method.
public struct PayByBankUSPaymentMethod: PaymentMethod, PaymentMethodDisplayOverridable {
    public let type: PaymentMethodType
    
    public var name: String

    package static var logoNames: [String] {
        ["US-1", "US-2", "US-3", "US-4"]
    }
    
    package func overriddenDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        .init(
            title: name,
            subtitle: nil,
            logoName: type.rawValue,
            trailingInfo: .logos(
                named: Self.logoNames,
                trailingText: "+"
            ),
            accessibilityLabel: name
        )
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}

// MARK: - PaymentComponentBuildable

extension PayByBankUSPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
