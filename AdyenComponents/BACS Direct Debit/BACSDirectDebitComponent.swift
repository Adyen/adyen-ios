//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

#if canImport(AdyenUI)
    import AdyenUI
#endif
import UIKit

/// A component that provides a form for BACS Direct Debit payments.
@MainActor
package final class BACSDirectDebitComponent: PaymentComponent {

    // MARK: - PaymentComponent

    package let viewController: UIViewController

    /// The object that acts as the delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    package let type: PaymentComponentType = .regular
    package let requiresUserInteraction: Bool = true

    /// The BACS Direct Debit payment method.
    package var paymentMethod: PaymentMethod {
        bacsPaymentMethod
    }

    /// The context object for this component.
    package let context: AdyenContext

    /// Component's configuration
    package var configuration: BasicComponentConfiguration

    // MARK: - PaymentComponent

    package func performSubmit() {
        bacsViewModel.performSubmit()
    }

    // MARK: - Properties

    internal let bacsPaymentMethod: BACSDirectDebitPaymentMethod

    internal let bacsViewModel: BACSViewModel

    // MARK: - Initializers

    /// Creates and returns a BACS Direct Debit component.
    ///
    /// - Note: Prefer creating instances via ``BACSDirectDebitFactory`` instead of calling
    /// this initializer directly, as it is responsible for assembling the view model and
    /// view controller dependencies.
    /// - Parameters:
    ///   - paymentMethod: The BACS Direct Debit payment method.
    ///   - context: The context object for this component.
    ///   - configuration: Configuration for the component.
    ///   - viewModel: The view model backing the component's form.
    ///   - viewController: The view controller presented by the component.
    package init(
        paymentMethod: BACSDirectDebitPaymentMethod,
        context: AdyenContext,
        configuration: BasicComponentConfiguration = .init(),
        viewModel: BACSViewModel,
        viewController: UIViewController
    ) {
        self.bacsPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.bacsViewModel = viewModel
        self.viewController = viewController
    }
}

// MARK: - LoadingComponent

/// :nodoc:
extension BACSDirectDebitComponent: LoadingComponent {

    /// Stops any processing animation that the component is running.
    package func stopLoading() {
        bacsViewModel.stopLoading()
    }
}
