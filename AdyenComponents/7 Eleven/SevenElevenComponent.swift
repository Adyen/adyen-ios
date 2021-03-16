//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for 7 Elevent  payments.
public final class SevenElevenComponent: AbstractPersonalInformationComponent {

    /// :nodoc:
    private let sevenElevenPaymentMethod: SevenElevenPaymentMethod

    /// Initializes the 7 Eleven component.
    ///
    /// - Parameter paymentMethod: The 7 Eleven payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: SevenElevenPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.sevenElevenPaymentMethod = paymentMethod
        let configuration = Configuration(fields: [.firstName, .lastName, .phone, .email])
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   style: style)
    }

    override public func getPhoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .generic)
        return PhoneExtensionsRepository.get(with: query)
    }

    override public func submitButtonTitle() -> String {
        ADYLocalizedString("adyen.confirmPurchase", localizationParameters)
    }

    override public func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstNameItem = firstNameItem,
              let lastNameItem = lastNameItem,
              let emailItem = emailItem,
              let phoneItem = phoneItem else {
            fatalError("There seems to be an error in the BaseFormComponent configuration.")
        }
        return SevenElevenDetails(paymentMethod: paymentMethod,
                                  firstName: firstNameItem.value,
                                  lastName: lastNameItem.value,
                                  emailAddress: emailItem.value,
                                  telephoneNumber: phoneItem.phoneNumber)
    }
}
