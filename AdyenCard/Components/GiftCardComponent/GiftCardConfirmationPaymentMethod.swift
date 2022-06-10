//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// A payment method wrapper, with custom `DisplayInformation`.
internal struct GiftCardConfirmationPaymentMethod: PaymentMethod {
    
    internal var type: PaymentMethodType {
        paymentMethod.type
    }
    
    internal var name: String {
        paymentMethod.name
    }
    
    internal var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation? {
        get { paymentMethod.merchantProvidedDisplayInformation }
        set { paymentMethod.merchantProvidedDisplayInformation = newValue }
    }
    
    private var paymentMethod: GiftCardPaymentMethod
    
    private let lastFour: String
    
    private let remainingAmount: Amount
    
    internal func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        paymentMethod.buildComponent(using: builder)
    }
    
    internal func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let footnote = localizedString(.partialPaymentRemainingBalance,
                                       parameters,
                                       remainingAmount.formatted)
        return DisplayInformation(title: String.Adyen.securedString + lastFour,
                                  subtitle: nil,
                                  logoName: paymentMethod.brand,
                                  footnoteText: footnote)
    }
    
    internal init(paymentMethod: GiftCardPaymentMethod,
                  lastFour: String,
                  remainingAmount: Amount) {
        self.paymentMethod = paymentMethod
        self.lastFour = lastFour
        self.remainingAmount = remainingAmount
    }
    
    internal init(from decoder: Decoder) throws {
        fatalError("This class should never be decoded.")
    }
    
    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
