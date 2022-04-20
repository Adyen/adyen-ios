//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for Doku Wallet, Doku Alfamart, and Doku Indomaret  payments.
public final class DokuComponent: AbstractPersonalInformationComponent {

    /// Configuration for Doku Component
    public typealias Configuration = PersonalInformationConfiguration
    
    /// :nodoc:
    private let dokuPaymentMethod: DokuPaymentMethod

    /// Initializes the Doku component.
    /// - Parameters:
    ///   - paymentMethod: The Doku Wallet, Doku Alfamart, or Doku Indomaret payment method.
    ///   - apiContext: The component's UI style.
    ///   - configuration: The component's configuration.
    public init(paymentMethod: DokuPaymentMethod,
                apiContext: APIContext,
                configuration: Configuration = .init()) {
        self.dokuPaymentMethod = paymentMethod
        super.init(paymentMethod: paymentMethod,
                   apiContext: apiContext,
                   fields: [.firstName, .lastName, .email],
                   configuration: configuration)
    }

    override public func submitButtonTitle() -> String {
        localizedString(.confirmPurchase, configuration.localizationParameters)
    }

    override public func createPaymentDetails() throws -> PaymentMethodDetails {
        guard let firstNameItem = firstNameItem,
              let lastNameItem = lastNameItem,
              let emailItem = emailItem else {
                  throw UnknownError(errorDescription: "There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
              }
        return DokuDetails(paymentMethod: paymentMethod,
                           firstName: firstNameItem.value,
                           lastName: lastNameItem.value,
                           emailAddress: emailItem.value)
    }
}
