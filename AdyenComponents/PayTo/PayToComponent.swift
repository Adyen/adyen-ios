//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component that provides PayTo flows for PayTo component.
public final class PayToComponent: PaymentComponent,
                                   PresentableComponent {

    /// Configuration for PayTo Component.
    public typealias Configuration = BasicComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// Component's configuration
    public var configuration: Configuration

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod { payToPaymentMethod }

    private let payToPaymentMethod: PayToPaymentMethod

    /// The viewController for the component.
    public lazy var viewController: UIViewController = .init()

    /// Initializes the PayTo  component.
    ///
    /// - Parameter paymentMethod: The PayTo payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(
        paymentMethod: PayToPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.payToPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }
}
