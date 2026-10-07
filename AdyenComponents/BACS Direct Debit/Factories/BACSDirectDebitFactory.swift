//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import UIKit

/// Assembly layer responsible for creating `BACSDirectDebitComponent` instances,
/// wiring up the view model and view controller dependencies.
@MainActor
package struct BACSDirectDebitFactory: PaymentComponentFactory {
    package typealias Configuration = BACSDirectDebitConfiguration
    package typealias Method = BACSDirectDebitPaymentMethod
    package typealias Component = BACSDirectDebitComponent

    package init() {}

    /// Creates a BACS Direct Debit payment component, assembling its view model
    /// and view controller dependencies.
    ///
    /// - Note: The tracker reads the component's `_isDropIn` flag when analytics are sent,
    /// since Drop-in sets it only after this factory returns the component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The BACS Direct Debit payment method.
    ///   - context: The context object.
    ///   - configuration: The configuration for the component.
    /// - Returns: A fully assembled BACS Direct Debit component.
    package func create(
        with paymentMethod: BACSDirectDebitPaymentMethod,
        context: AdyenContext,
        configuration: BACSDirectDebitConfiguration
    ) -> BACSDirectDebitComponent {
        weak var weakComponent: BACSDirectDebitComponent?

        let tracker = BACSDirectDebitComponentTracker(
            paymentMethod: paymentMethod,
            context: context,
            isDropIn: { weakComponent?._isDropIn ?? false }
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
                guard let component = weakComponent else { return }
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

        let component = BACSDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            viewModel: viewModel,
            viewController: viewController
        )
        weakComponent = component

        return component
    }

    package func defaultConfiguration() -> BACSDirectDebitConfiguration {
        BACSDirectDebitConfiguration()
    }

    package func isAvailable(
        for _: Method,
        configuration _: Configuration
    ) -> Bool {
        true
    }
}
