//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that provides a form for Qiwi Wallet payments.
public final class QiwiWalletComponent: PhoneBasedPaymentComponent {
    
    /// :nodoc:
    private let qiwiWalletPaymentMethod: QiwiWalletPaymentMethod
    
    /// Initializes the Qiwi Wallet component.
    ///
    /// - Parameter paymentMethod: The Qiwi Wallet payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: QiwiWalletPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.qiwiWalletPaymentMethod = paymentMethod
        super.init(paymentMethod: paymentMethod, style: style)
    }

    override internal func getPhoneExtensions() -> [PhoneExtension] { qiwiWalletPaymentMethod.phoneExtensions
    }

    override internal func createPaymentDetails() -> PaymentMethodDetails {
        QiwiWalletDetails(paymentMethod: paymentMethod,
                          phonePrefix: phoneNumberItem.prefix,
                          phoneNumber: phoneNumberItem.value)
    }
    
}
