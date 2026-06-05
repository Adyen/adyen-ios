//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import protocol Adyen.ShopperInformation

/// Contains the details supplied by the ACH Direct Debit component.
package struct ACHDirectDebitDetails: PaymentMethodDetails, ShopperInformation {
    
    package var checkoutAttemptId: String?

    /// The payment method type.
    package let type: PaymentMethodType

    /// The name of the bank account holder.
    package let holderName: String

    /// The encrypted bank account number (without separators).
    package let encryptedBankAccountNumber: String

    /// The encrypted bank routing number of the account.
    package let encryptedBankRoutingNumber: String?

    /// The shopper's billing address.
    package let billingAddress: PostalAddress?

    /// An encoded string containing important SDK-specific data.
    /// It is recommended to pass this field to your server to ensure maximum performance and reliability.
    package var sdkData: String?

    /// Initializes the ACH Direct Debit details.
    /// - Parameters:
    ///   - paymentMethod: ACH Direct Debit payment method.
    ///   - holderName: Name of the account holder.
    ///   - encryptedBankAccountNumber: Encrypted bank account number.
    ///   - encryptedBankRoutingNumber: Encrypted bank routing number.
    ///   - billingAddress: Billing address.
    package init(paymentMethod: ACHDirectDebitPaymentMethod, holderName: String, encryptedBankAccountNumber: String, encryptedBankRoutingNumber: String?, billingAddress: PostalAddress?) {
        self.type = paymentMethod.type
        self.holderName = holderName
        self.encryptedBankAccountNumber = encryptedBankAccountNumber
        self.encryptedBankRoutingNumber = encryptedBankRoutingNumber
        self.billingAddress = billingAddress
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case holderName = "ownerName"
        case encryptedBankAccountNumber
        case encryptedBankRoutingNumber = "encryptedBankLocationId"
        case sdkData
    }
}
