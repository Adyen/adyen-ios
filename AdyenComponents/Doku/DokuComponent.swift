//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey

#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormTextItem
#endif
import Foundation
import UIKit

/// A component that provides a form for Doku Wallet, Doku Alfamart, and Doku Indomaret  payments.
package final class DokuComponent: AbstractPersonalInformationComponent {

    /// Configuration for Doku Component
    package typealias Configuration = PersonalInformationConfiguration

    private let dokuPaymentMethod: DokuPaymentMethod

    /// Initializes the Doku component.
    /// - Parameters:
    ///   - paymentMethod: The Doku Wallet, Doku Alfamart, or Doku Indomaret payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The component's configuration.
    package init(
        paymentMethod: DokuPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.dokuPaymentMethod = paymentMethod
        super.init(
            paymentMethod: paymentMethod,
            context: context,
            fields: [.firstName, .lastName, .email],
            configuration: configuration
        )
    }

    @_spi(AdyenInternal)
    override public func submitButtonTitle() -> String {
        localizedString(.confirmPurchase, configuration.localizationParameters)
    }

    @_spi(AdyenInternal)
    override public func createPaymentDetails() throws -> PaymentMethodDetails {
        guard let firstNameItem,
              let lastNameItem,
              let emailItem else {
            throw UnknownError(errorDescription: "There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        return DokuDetails(
            paymentMethod: paymentMethod,
            firstName: firstNameItem.value,
            lastName: lastNameItem.value,
            emailAddress: emailItem.value
        )
    }
}
