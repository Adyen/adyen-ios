//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// Factory for creating ACH Direct Debit payment components.
///
/// This factory creates `ACHDirectDebitComponent` instances configured with the
/// provided ACH payment method and component configuration.
package struct ACHDirectDebitComponentFactory: PaymentComponentFactory {
    package typealias Configuration = ACHDirectDebitComponentConfiguration
    package typealias Method = ACHDirectDebitPaymentMethod
    package typealias Component = ACHDirectDebitComponent

    package init() {}

    /// Creates an ACH Direct Debit payment component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The payment method for the component.
    ///   - context: The context object.
    ///   - configuration: The configuration for the component.
    /// - Returns: A configured ACH Direct Debit component.
    package func create(
        with paymentMethod: ACHDirectDebitPaymentMethod,
        context: AdyenContext,
        configuration: ACHDirectDebitComponentConfiguration,
        publicKey: String
    ) -> ACHDirectDebitComponent {
        ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
    }

    package func defaultConfiguration() -> ACHDirectDebitComponentConfiguration {
        ACHDirectDebitComponentConfiguration()
    }
}
