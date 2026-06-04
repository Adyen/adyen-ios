//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any Mealvoucher payment method.
public struct MealVoucherPaymentMethod: PartialPaymentMethod, PaymentMethodDisplayOverridable {

    public let type: PaymentMethodType

    public let name: String
    
    package func overriddenDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        DisplayInformation(title: name, subtitle: nil, logoName: type.rawValue)
    }

    // MARK: - Decoding

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }

}

// MARK: - PaymentComponentBuildable

extension MealVoucherPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
