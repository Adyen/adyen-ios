//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Contains the details supplied by the ACH Direct Debit component.
public struct ACHDirectDebitDetails: PaymentMethodDetails, ShopperInformation {
    
    /// The payment method type.
    public let type: String

    /// The name of the bank account holder.
    public let holderName: String

    /// The encrypted bank account number (without separators).
    public let encryptedBankAccountNumber: String

    /// The encrypted bank routing number of the account.
    public let encryptedBankRoutingNumber: String?
    
    /// The shopper's billing address.
    public let billingAddress: PostalAddress?
    
    /// Initializes the ACH Direct Debit details.
    /// - Parameters:
    ///   - paymentMethod: ACH Direct Debit payment method.
    ///   - holderName: Name of the account holder.
    ///   - encryptedBankAccountNumber: Encrypted bank account number.
    ///   - encryptedBankRoutingNumber: Encrypted bank routing number.
    ///   - billingAddress: Billing address.
    public init(paymentMethod: ACHDirectDebitPaymentMethod, holderName: String, encryptedBankAccountNumber: String, encryptedBankRoutingNumber: String?, billingAddress: PostalAddress?) {
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
    }
}
