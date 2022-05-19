//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component that provides a form for Qiwi Wallet payments.
public final class QiwiWalletComponent: AbstractPersonalInformationComponent {
    
    /// Configuration for Qiwi Wallet Component
    public typealias Configuration = PersonalInformationConfiguration
    
    private let qiwiWalletPaymentMethod: QiwiWalletPaymentMethod
    
    /// Initializes the Qiwi Wallet component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The Qiwi Wallet payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The component's configuration.
    public init(paymentMethod: QiwiWalletPaymentMethod,
                context: AdyenContext,
                configuration: Configuration = .init()) {
        self.qiwiWalletPaymentMethod = paymentMethod
        super.init(paymentMethod: paymentMethod,
                   context: context,
                   fields: [.phone],
                   configuration: configuration)
    }

    @_spi(AdyenInternal)
    override public func submitButtonTitle() -> String {
        localizedString(.continueTo, configuration.localizationParameters, paymentMethod.name)
    }

    @_spi(AdyenInternal)
    override public func phoneExtensions() -> [PhoneExtension] { qiwiWalletPaymentMethod.phoneExtensions
    }

    @_spi(AdyenInternal)
    override public func createPaymentDetails() throws -> PaymentMethodDetails {
        guard let phoneItem = phoneItem else {
            throw UnknownError(errorDescription: "There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        return QiwiWalletDetails(paymentMethod: paymentMethod,
                                 phonePrefix: phoneItem.prefix,
                                 phoneNumber: phoneItem.value)
    }
    
}
