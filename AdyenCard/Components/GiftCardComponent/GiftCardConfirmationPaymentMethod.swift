//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey

/// A payment method wrapper, with custom `DisplayInformation`.
internal struct PartialConfirmationPaymentMethod: PaymentMethod, PaymentMethodDisplayOverridable {
    
    internal var type: PaymentMethodType {
        paymentMethod.type
    }
    
    internal var name: String {
        paymentMethod.name
    }
    
    private var paymentMethod: PartialPaymentMethod
    
    private let lastFour: String
    
    private let remainingAmount: Amount
        
    package func overriddenDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let footnote = localizedString(
            .partialPaymentRemainingBalance,
            parameters,
            remainingAmount.formatted
        )
        let lastFourSeparated = lastFour.map { String($0) }.joined(separator: ", ")
        
        let accessibilityLabel = [
            name,
            "\(localizedString(.accessibilityLastFourDigits, parameters)): \(lastFourSeparated)",
            footnote
        ].joined(separator: ", ")
        
        return DisplayInformation(
            title: String.Adyen.securedString + lastFour,
            subtitle: nil,
            logoName: paymentMethod.displayInformation(using: parameters).logoName,
            footnoteText: footnote,
            accessibilityLabel: accessibilityLabel
        )
    }
    
    internal init(
        paymentMethod: some PartialPaymentMethod,
        lastFour: String,
        remainingAmount: Amount
    ) {
        self.paymentMethod = paymentMethod
        self.lastFour = lastFour
        self.remainingAmount = remainingAmount
    }
    
    internal init(from decoder: Decoder) throws {
        // We have to conform to Codable because `PaymentMethod` requires it
        // but this struct should never be encoded/decoded as it's an intermediate state
        fatalError("This class should never be decoded.")
    }
    
    internal func encode(to encoder: Encoder) throws {
        // We have to conform to Codable because `PaymentMethod` requires it
        // but this struct should never be encoded/decoded as it's an intermediate state
        fatalError("This class should never be encoded.")
    }
}

extension PartialConfirmationPaymentMethod: PaymentComponentBuildable {
    internal func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        (paymentMethod as? PaymentComponentBuildable)?.buildComponent(using: builder)
    }
}
