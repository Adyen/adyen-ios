//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that provides a form for Qiwi Wallet payments.
public final class QiwiWalletComponent: AbstractPersonalInformationComponent {
    
    /// :nodoc:
    private let qiwiWalletPaymentMethod: QiwiWalletPaymentMethod
    
    /// Initializes the Qiwi Wallet component.
    ///
    /// - Parameter paymentMethod: The Qiwi Wallet payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: QiwiWalletPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.qiwiWalletPaymentMethod = paymentMethod
        let configuration = Configuration(fields: [.phone])
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   style: style)
    }

    override public func submitButtonTitle() -> String {
        ADYLocalizedString("adyen.continueTo", localizationParameters, paymentMethod.name)
    }

    override public func getPhoneExtensions() -> [PhoneExtension] { qiwiWalletPaymentMethod.phoneExtensions
    }

    override public func createPaymentDetails() -> PaymentMethodDetails {
        guard let phoneItem = phoneItem else {
            fatalError("There seems to be an error in the BaseFormComponent configuration.")
        }
        return QiwiWalletDetails(paymentMethod: paymentMethod,
                                 phonePrefix: phoneItem.prefix,
                                 phoneNumber: phoneItem.value)
    }
    
}
