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
        let configuration = BaseFormComponent.Configuration(fields: [.firstName, .lastName, .email])
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   style: style)
    }

    override public func submitButtonTitle() -> String {
        ADYLocalizedString("adyen.confirmPurchase", localizationParameters)
    }

    override public func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstNameItem = firstNameItem,
              let lastNameItem = lastNameItem,
              let emailItem = emailItem else {
            fatalError("There seems to be an error in the BaseFormComponent configuration.")
        }
        return DokuWalletDetails(paymentMethod: paymentMethod,
                                 firstName: firstNameItem.value,
                                 lastName: lastNameItem.value,
                                 emailAddress: emailItem.value)
    }
}
