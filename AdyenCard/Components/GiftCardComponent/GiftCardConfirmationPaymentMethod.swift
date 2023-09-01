//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// A payment method wrapper, with custom `DisplayInformation`.
struct PartialConfirmationPaymentMethod: PaymentMethod {
    
    var type: PaymentMethodType {
        paymentMethod.type
    }
    
    var name: String {
        paymentMethod.name
    }
    
    var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation? {
        get { paymentMethod.merchantProvidedDisplayInformation }
        set { paymentMethod.merchantProvidedDisplayInformation = newValue }
    }
    
    private var paymentMethod: PartialPaymentMethod
    
    private let lastFour: String
    
    private let remainingAmount: Amount
    
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        paymentMethod.buildComponent(using: builder)
    }
    
    func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let footnote = localizedString(.partialPaymentRemainingBalance,
                                       parameters,
                                       remainingAmount.formatted)
        return DisplayInformation(title: String.Adyen.securedString + lastFour,
                                  subtitle: nil,
                                  logoName: paymentMethod.displayInformation(using: parameters).logoName,
                                  footnoteText: footnote)
    }
    
    init(paymentMethod: some PartialPaymentMethod,
         lastFour: String,
         remainingAmount: Amount) {
        self.paymentMethod = paymentMethod
        self.lastFour = lastFour
        self.remainingAmount = remainingAmount
    }
    
    init(from decoder: Decoder) throws {
        fatalError("This class should never be decoded.")
    }
    
    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
