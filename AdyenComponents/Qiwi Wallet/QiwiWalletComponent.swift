//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that provides a form for Qiwi Wallet payments.
public final class QiwiWalletComponent: AbstractPersonalInformationComponent {
    
    /// Configuration for Qiwi Wallet Component
    public typealias Configuration = PersonalInformationConfiguration
    
    /// :nodoc:
    private let qiwiWalletPaymentMethod: QiwiWalletPaymentMethod
    
    /// Initializes the Qiwi Wallet component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Qiwi Wallet payment method.
    ///   - apiContext: The component's API context.
    ///   - configuration: The component's configuration.
    public init(paymentMethod: QiwiWalletPaymentMethod,
                apiContext: APIContext,
                configuration: Configuration = .init()) {
        self.qiwiWalletPaymentMethod = paymentMethod
        super.init(paymentMethod: paymentMethod,
                   apiContext: apiContext,
                   fields: [.phone],
                   configuration: configuration)
    }

    override public func submitButtonTitle() -> String {
        localizedString(.continueTo, configuration.localizationParameters, paymentMethod.name)
    }

    override public func phoneExtensions() -> [PhoneExtension] { qiwiWalletPaymentMethod.phoneExtensions
    }

    override public func createPaymentDetails() throws -> PaymentMethodDetails {
        guard let phoneItem = phoneItem else {
            throw UnknownError(errorDescription: "There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        return QiwiWalletDetails(paymentMethod: paymentMethod,
                                 phonePrefix: phoneItem.prefix,
                                 phoneNumber: phoneItem.value)
    }
    
}
