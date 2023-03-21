//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// Containts the details supplied by the Cash App Pay component.
public struct CashAppPayDetails: PaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
    /// The payment method type.
    public let type: PaymentMethodType
    
    /// The grant Id for the payment.
    public let grantId: String
    
    /// Creates and returns a Cash App Pay details instance.
    /// - Parameters:
    ///   - paymentMethod: Cash App Pay payment method.
    ///   - grantId: The grant Id for the payment.
    public init(paymentMethod: CashAppPayPaymentMethod,
                grantId: String) {
        self.type = paymentMethod.type
        self.grantId = grantId
    }
    
    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case grantId
    }
}
