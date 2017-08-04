//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents a payment that has been completed by the user. The result of the payment can be retrieved via the `status` property.
public final class Payment {
    
    /// The status of the payment.
    public let status: PaymentStatus
    
    /// The method that was used to complete the payment.
    public let method: PaymentMethod
    
    /// The payload as returned from the server.
    public let payload: String
    
    /// The amount of the payment, in minor units.
    public let amount: Int
    
    /// The code of the currency for the payment amount.
    public let currencyCode: String
    
    /// The reference of the merchant.
    public let merchantReference: String
    
    /// The reference of the shopper.
    public let shopperReference: String?
    
    /// The country code of the shopper.
    public let shopperCountryCode: String
    
    /// The locale identifier of the shopper.
    public let shopperLocaleIdentifier: String?
    
    internal init(status: PaymentStatus, method: PaymentMethod, payload: String, paymentSetup: PaymentSetup) {
        self.status = status
        self.method = method
        self.payload = payload
        self.amount = paymentSetup.amount
        self.currencyCode = paymentSetup.currencyCode
        self.merchantReference = paymentSetup.merchantReference
        self.shopperReference = paymentSetup.shopperReference
        self.shopperCountryCode = paymentSetup.countryCode
        self.shopperLocaleIdentifier = paymentSetup.shopperLocaleIdentifier
    }
}
