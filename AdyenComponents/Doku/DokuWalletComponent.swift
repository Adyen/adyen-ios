//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for Doku Wallet payments.
public final class DokuWalletComponent: BaseFormComponent {

    /// :nodoc:
    private let dokuWalletPaymentMethod: DokuWalletPaymentMethod

    /// Initializes the Doku component.
    ///
    /// - Parameter paymentMethod: The Doku Wallet payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: DokuWalletPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.dokuWalletPaymentMethod = paymentMethod
        super.init(paymentMethod: paymentMethod, style: style)
    }

    override public func submitButtonTitle() -> String {
        ADYLocalizedString("adyen.confirmPurchase", localizationParameters)
    }

    override public func createPaymentDetails(_ details: BaseFormDetails) -> PaymentMethodDetails {
        guard let firstName = details.firstName,
              let lastName = details.lastName,
              let email = details.emailAddress else {
            fatalError("There seems to be an error in the BaseFormComponent configuration.")
        }
        return DokuWalletDetails(paymentMethod: paymentMethod,
                                 firstName: firstName,
                                 lastName: lastName,
                                 emailAddress: email)
    }

    override public func createConfiguration() -> Configuration {
        let fields: [BaseFormField] = [.firstName(firstNameElement),
                                       .lastName(lastNameElement),
                                       .email(emailElement)]
        return BaseFormComponent.Configuration(fields: fields)
    }

    private lazy var firstNameElement: FirstNameElement = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "firstNameItem")
        return FirstNameElement(identifier: identifier,
                                style: style.textField)
    }()

    private lazy var lastNameElement: LastNameElement = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "lastNameItem")
        return LastNameElement(identifier: identifier,
                               style: style.textField)
    }()

    private lazy var emailElement: EmailElement = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "emailItem")
        return EmailElement(identifier: identifier,
                            style: style.textField)
    }()
}
