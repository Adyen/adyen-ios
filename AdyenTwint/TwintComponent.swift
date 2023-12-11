//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import TwintSDK

public final class TwintComponent {

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod { twintPayPaymentMethod }

    private let twintPayPaymentMethod: TwintPaymentMethod

    public var requiresModalPresentation: Bool = true

    /// Initializes the Twint component.
    ///
    /// - Parameter paymentMethod: The Twint  payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(paymentMethod: TwintPaymentMethod,
                context: AdyenContext) {
        self.twintPayPaymentMethod = paymentMethod
        self.context = context
    }

    private func startTwintFlow() {
        
    }
}
