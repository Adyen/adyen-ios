//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for Doku Wallet, Doku Alfamart, and Doku Indomaret  payments.
public final class DokuComponent: AbstractPersonalInformationComponent {

    /// :nodoc:
    private let dokuPaymentMethod: DokuPaymentMethod

    /// Initializes the Doku component.
    ///
    /// - Parameter paymentMethod: The Doku Wallet, Doku Alfamart, or Doku Indomaret payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: DokuPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.dokuPaymentMethod = paymentMethod
        let configuration = Configuration(fields: [.firstName, .lastName, .email])
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
        return DokuDetails(paymentMethod: paymentMethod,
                           firstName: firstNameItem.value,
                           lastName: lastNameItem.value,
                           emailAddress: emailItem.value)
    }
}
