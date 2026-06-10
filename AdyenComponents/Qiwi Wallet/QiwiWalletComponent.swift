//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormValueItem
#endif
import UIKit

/// A component that provides a form for Qiwi Wallet payments.
package final class QiwiWalletComponent: AbstractPersonalInformationComponent {

    /// Configuration for Qiwi Wallet Component
    package typealias Configuration = PersonalInformationConfiguration

    private let qiwiWalletPaymentMethod: QiwiWalletPaymentMethod
    
    /// Initializes the Qiwi Wallet component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Qiwi Wallet payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The component's configuration.
    package init(
        paymentMethod: QiwiWalletPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.qiwiWalletPaymentMethod = paymentMethod
        super.init(
            paymentMethod: paymentMethod,
            context: context,
            fields: [.phone],
            configuration: configuration
        )
    }

    override package func submitButtonTitle() -> String {
        localizedString(.continueTo, configuration.localizationParameters, paymentMethod.name)
    }

    override package func phoneExtensions() -> [PhoneExtension] {
        qiwiWalletPaymentMethod.phoneExtensions
    }

    override package func createPaymentDetails() throws -> PaymentMethodDetails {
        guard let phoneItem else {
            throw UnknownError(errorDescription: "There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        return QiwiWalletDetails(
            paymentMethod: paymentMethod,
            phonePrefix: phoneItem.prefix,
            phoneNumber: phoneItem.value
        )
    }
    
}
