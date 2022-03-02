//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Configuration for Qiwi Wallet Component
public typealias QiwiWalletComponentConfiguration = PersonalInformationConfiguration

/// A component that provides a form for Qiwi Wallet payments.
public final class QiwiWalletComponent: AbstractPersonalInformationComponent {
    
    /// :nodoc:
    private let qiwiWalletPaymentMethod: QiwiWalletPaymentMethod
    
    /// Initializes the Qiwi Wallet component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Qiwi Wallet payment method.
    ///   - apiContext: The component's API context.
    ///   - adyenContext: The Adyen context.
    ///   - configuration: The component's configuration.
    public init(paymentMethod: QiwiWalletPaymentMethod,
                apiContext: APIContext,
                adyenContext: AdyenContext,
                configuration: QiwiWalletComponentConfiguration) {
        self.qiwiWalletPaymentMethod = paymentMethod
        super.init(paymentMethod: paymentMethod,
                   apiContext: apiContext,
                   adyenContext: adyenContext,
                   fields: [.phone],
                   configuration: configuration)
    }

    override public func submitButtonTitle() -> String {
        localizedString(.continueTo, configuration.localizationParameters, paymentMethod.name)
    }

    override public func phoneExtensions() -> [PhoneExtension] { qiwiWalletPaymentMethod.phoneExtensions
    }

    override public func createPaymentDetails() -> PaymentMethodDetails {
        guard let phoneItem = phoneItem else {
            fatalError("There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        return QiwiWalletDetails(paymentMethod: paymentMethod,
                                 phonePrefix: phoneItem.prefix,
                                 phoneNumber: phoneItem.value)
    }
    
}
