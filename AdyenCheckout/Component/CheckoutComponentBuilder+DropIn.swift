//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenDropIn

extension CheckoutComponentBuilder {

    @MainActor
    // swiftlint:disable:next function_parameter_count
    package static func buildDropIn(
        paymentMethods: PaymentMethods,
        configuration: CheckoutConfiguration,
        context: AdyenContext,
        actionComponentConfiguration: CheckoutActionComponent.Configuration,
        storedPaymentMethodManagementCapability: StoredPaymentMethodManagementCapability?,
        paymentComponentBuilder: @escaping DropInPaymentComponentBuilder
    ) -> DropInComponent {
        var dropInConfiguration = configuration.dropInConfiguration
        dropInConfiguration.theme = configuration.theme
        dropInConfiguration.localizationProvider = configuration.localizationProvider

        return DropInComponent(
            paymentMethods: paymentMethods,
            context: context,
            configuration: dropInConfiguration,
            actionComponentConfiguration: actionComponentConfiguration,
            storedMethodManagementSource: .checkout(storedPaymentMethodManagementCapability),
            paymentComponentBuilder: paymentComponentBuilder
        )
    }
}
