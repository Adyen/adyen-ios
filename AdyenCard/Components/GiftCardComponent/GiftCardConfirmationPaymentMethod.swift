//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// A payment method wrapper, with custom `DisplayInformation`.
internal struct PartialConfirmationPaymentMethod: PaymentMethod {
    
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
    
    private var paymentMethod: PartialPaymentMethod
    
    private let lastFour: String
    
    private let remainingAmount: Amount
    
    internal func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        paymentMethod.buildComponent(using: builder)
    }
    
    internal func defaultDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        let footnote = localizedString(.partialPaymentRemainingBalance,
                                       parameters,
                                       remainingAmount.formatted)
        let lastFourSeparated = lastFour.map { String($0) }.joined(separator: ", ")
        
        let accessibilityLabel = [
            name,
            "\(localizedString(.accessibilityLastFourDigits, parameters)): \(lastFourSeparated)",
            footnote
        ].joined(separator: ", ")
        
        return DisplayInformation(title: String.Adyen.securedString + lastFour,
                                  subtitle: nil,
                                  logoName: paymentMethod.displayInformation(using: parameters).logoName,
                                  footnoteText: footnote,
                                  accessibilityLabel: accessibilityLabel)
    }
    
    internal init(paymentMethod: some PartialPaymentMethod,
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
