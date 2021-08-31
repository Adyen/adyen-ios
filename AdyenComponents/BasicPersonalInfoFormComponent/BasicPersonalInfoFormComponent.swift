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
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - apiContext: The component's API context.
    ///   - style: The component's UI style.
    ///   - shopperInformation: The shopper's information.
    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                shopperInformation: PrefilledShopperInformation? = nil,
                style: FormComponentStyle = FormComponentStyle()) {
        let configuration = Configuration(fields: [.firstName, .lastName, .phone, .email])
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   apiContext: apiContext,
                   shopperInformation: shopperInformation,
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
