//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Payment result information.
public final class Payment {
    
    /// Payment object.
    let payment: InternalPaymentRequest
    
    /// Status of the payment.
    public let status: PaymentStatus
    
    /// Payment payload.
    public let payload: String
    
    /// The `PaymentMethod` used in the payment.
    private(set) public var method: PaymentMethod?
    
    /// Payment amount.
    private(set) public var amount: Int?
    
    /// Payment currency.
    private(set) public var currency: String?
    
    /// Payment reference.
    private(set) public var reference: String?
    
    /// Payment country code.
    private(set) public var countryCode: String?
    
    /// Locale of the shopper.
    private(set) public var shopperLocale: String?
    
    /// Shopper reference.
    private(set) public var shopperReference: String?
    
    init(payment: InternalPaymentRequest, status: PaymentStatus, payload: String) {
        self.payment = payment
        self.status = status
        self.payload = payload
    }
}
