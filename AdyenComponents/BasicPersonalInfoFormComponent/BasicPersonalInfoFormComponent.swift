//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form consisting of first name, last name, phone, and email.
/// :nodoc:
public final class BasicPersonalInfoFormComponent: AbstractPersonalInformationComponent {

    /// Initializes the component.
    ///
    /// - Parameter paymentMethod: The payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: PaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
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
        localizedString(.confirmPurchase, localizationParameters)
    }

    override public func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstNameItem = firstNameItem,
              let lastNameItem = lastNameItem,
              let emailItem = emailItem,
              let phoneItem = phoneItem else {
            fatalError("There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        return BasicPersonalInfoFormDetails(paymentMethod: paymentMethod,
                                            firstName: firstNameItem.value,
                                            lastName: lastNameItem.value,
                                            emailAddress: emailItem.value,
                                            telephoneNumber: phoneItem.phoneNumber)
    }
}

/// Provides an form for personal information, requred for E-context ATM  payments.
public typealias EContextATMComponent = BasicPersonalInfoFormComponent

/// Provides an form for personal information, requred for E-context Store payments.
public typealias EContextStoreComponent = BasicPersonalInfoFormComponent

/// Provides an form for personal information, requred for E-context Online  payments.
public typealias EContextOnlineComponent = BasicPersonalInfoFormComponent

/// Provides an form for personal information, requred for 7eleven  payments.
public typealias SevenElevenComponent = BasicPersonalInfoFormComponent
