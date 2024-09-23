//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// Contains the details supplied by the Cash App Pay component.
public struct CashAppPayDetails: PaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
    /// The payment method type.
    public let type: PaymentMethodType
    
    /// The grant Id for the payment.
    public let grantId: String?
    
    /// Grant id for recurring payments.
    public let onFileGrantId: String?
    
    /// Unique identifier for this customer issued by Cash App.
    public let customerId: String?
    
    /// Public identifier for the customer on Cash App.
    public let cashtag: String?
    
    /// Initializes the Cash App Pay details.
    /// - Parameters:
    ///   - paymentMethod: Cash App Pay payment method.
    ///   - grantId: The grant Id for the payment.
    ///   - onFileGrantId: Grant id for recurring payments.
    ///   - customerId: Unique identifier for this customer issued by Cash App.
    ///   - cashtag: Public identifier for the customer on Cash App.
    public init(
        paymentMethod: CashAppPayPaymentMethod,
        grantId: String?,
        onFileGrantId: String?,
        customerId: String?,
        cashtag: String?
    ) {
        self.type = paymentMethod.type
        self.grantId = grantId
        self.onFileGrantId = onFileGrantId
        self.customerId = customerId
        self.cashtag = cashtag
    }
    
    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case grantId
        case onFileGrantId
        case customerId
        case cashtag
    }
}
