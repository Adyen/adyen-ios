//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard

extension CardComponent {

    /// Creates a card component with empty callbacks, for tests that don't observe card events.
    convenience init(
        paymentMethod: AnyCardPaymentMethod,
        context: AdyenContext,
        configuration: CardConfiguration = .init()
    ) {
        self.init(paymentMethod: paymentMethod, context: context, configuration: configuration, callbacks: CardCallbacks())
    }
}

extension BCMCComponent {

    /// Creates a BCMC component with empty callbacks, for tests that don't observe card events.
    convenience init(
        paymentMethod: BCMCPaymentMethod,
        context: AdyenContext,
        configuration: CardConfiguration = .init()
    ) {
        self.init(paymentMethod: paymentMethod, context: context, configuration: configuration, callbacks: CardCallbacks())
    }
}
