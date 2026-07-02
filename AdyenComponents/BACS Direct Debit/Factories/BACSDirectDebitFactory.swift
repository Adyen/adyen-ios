//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import struct AdyenUI.BasicComponentConfiguration
#endif
import UIKit

/// Assembly layer responsible for creating `BACSDirectDebitComponent` instances,
/// wiring up the view model and view controller dependencies.
@MainActor
package struct BACSDirectDebitFactory: PaymentComponentFactory {
    package typealias Configuration = BACSDirectDebitComponent.Configuration
    package typealias Method = BACSDirectDebitPaymentMethod
    package typealias Component = BACSDirectDebitComponent

    package init() {}

    /// Creates a BACS Direct Debit payment component, assembling its view model
    /// and view controller dependencies.
    ///
    /// - Note: The tracker created here always reports `isDropIn: false`, since
    /// this factory runs before Drop-in has a chance to set `_isDropIn` on the
    /// resulting component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The BACS Direct Debit payment method.
    ///   - context: The context object.
    ///   - configuration: The configuration for the component.
    /// - Returns: A fully assembled BACS Direct Debit component.
    package func create(
        with paymentMethod: BACSDirectDebitPaymentMethod,
        context: AdyenContext,
        configuration: BACSDirectDebitComponent.Configuration
    ) -> BACSDirectDebitComponent {
        var component: BACSDirectDebitComponent!

        let tracker = BACSDirectDebitComponentTracker(
            paymentMethod: paymentMethod,
            context: context,
            isDropIn: false
        )
        let itemsFactory = BACSItemsFactory(
            styleProvider: configuration.style,
            localizationParameters: configuration.localizationParameters,
            scope: String(describing: BACSDirectDebitComponent.self)
        )

        let viewModel = BACSViewModel(
            paymentMethod: paymentMethod,
            amount: context.amount,
            configuration: configuration,
            tracker: tracker,
            itemsFactory: itemsFactory,
            onSubmit: { details in
                let data = PaymentComponentData(
                    paymentMethodDetails: details,
                    order: component.order
                )
                component.submit(data: data)
            }
        )

        let bacsViewController = BACSViewController(
            title: paymentMethod.name,
            viewModel: viewModel
        )
        let viewController = SecuredViewController(child: bacsViewController, style: configuration.style)

        component = BACSDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            viewModel: viewModel,
            viewController: viewController
        )

        return component
    }

    package func defaultConfiguration() -> BACSDirectDebitComponent.Configuration {
        BACSDirectDebitComponent.Configuration()
    }
}
