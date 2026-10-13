//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Contains the details supplied by the BACS Direct Debit component.
public struct BACSDirectDebitDetails: PaymentMethodDetails, ShopperInformation {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?

    /// The payment method type.
    public let type: PaymentMethodType

    /// The BACS account's holder name.
    public let holderName: String

    /// The BACS account's number.
    public let bankAccountNumber: String

    /// The BACS location's ID.
    public let bankLocationId: String

    /// The shopper's email address.
    public let shopperEmail: String?

    /// An encoded string containing important SDK-specific data.
    /// It is recommended to pass this field to your server to ensure maximum performance and reliability.
    public var sdkData: String?

    /// Creates and returns a BACS Direct Debit details instance.
    /// - Parameters:
    ///   - paymentMethod: The BACS Direct Debit payment method.
    ///   - holderName: The BACS account's holder name.
    ///   - bankAccountNumber: The BACS account's number.
    ///   - bankLocationId: The BACS location's ID.
    ///   - shopperEmail: The shopper's email address.
    public init(
        paymentMethod: BACSDirectDebitPaymentMethod,
        holderName: String,
        bankAccountNumber: String,
        bankLocationId: String,
        shopperEmail: String? = nil
    ) {
        self.type = paymentMethod.type
        self.holderName = holderName
        self.bankAccountNumber = bankAccountNumber
        self.bankLocationId = bankLocationId
        self.shopperEmail = shopperEmail
    }

    // MARK: - ShopperInformation

    package var emailAddress: String? {
        shopperEmail
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case holderName
        case bankAccountNumber
        case bankLocationId
        case sdkData
    }
}
