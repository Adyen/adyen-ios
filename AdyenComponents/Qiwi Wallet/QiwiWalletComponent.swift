//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that provides a form for Qiwi Wallet payments.
public final class QiwiWalletComponent: BaseFormComponent {
    
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

    override public func submitButtonTitle() -> String {
        ADYLocalizedString("adyen.continueTo", localizationParameters, paymentMethod.name)
    }

    override public func createPaymentDetails(_ details: BaseFormDetails) -> PaymentMethodDetails {
        guard let phonePrefix = details.phonePrefix,
              let phoneNumber = details.phoneNumber else {
            fatalError("There seems to be an error in the BaseFormComponent configuration.")
        }
        return QiwiWalletDetails(paymentMethod: paymentMethod,
                                 phonePrefix: phonePrefix,
                                 phoneNumber: phoneNumber)
    }

    override public func createConfiguration() -> Configuration {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneNumberItem")

        let phoneElement = PhoneElement(identifier: identifier,
                                        phoneExtensions: getPhoneExtensions(),
                                        style: style.textField)
        return BaseFormComponent.Configuration(fields: [.phone(phoneElement)])
    }

    private func getPhoneExtensions() -> [PhoneExtensionPickerItem] {
        qiwiWalletPaymentMethod.phoneExtensions.map {
            let title = "\($0.countryDisplayName) (\($0.value))"
            return PhoneExtensionPickerItem(identifier: $0.countryCode,
                                            title: title,
                                            phoneExtension: $0.value)

        }
    }
    
}
