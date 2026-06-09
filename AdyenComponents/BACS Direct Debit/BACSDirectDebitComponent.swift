//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import protocol Adyen.PresentableComponent

#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import struct AdyenUI.BasicComponentConfiguration
#endif
import UIKit

/// A component that provides a form for BACS Direct Debit payments.
@MainActor
package final class BACSDirectDebitComponent: PaymentComponent, PresentableComponent {

    /// Configuration for BACS Direct Debit Component.
    package typealias Configuration = BasicComponentConfiguration

    // MARK: - PresentableComponent

    package lazy var viewController: UIViewController = {
        let bacsViewController = createViewController()
        return SecuredViewController(child: bacsViewController, style: configuration.style)
    }()

    /// The object that acts as the delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    /// The BACS Direct Debit payment method.
    package var paymentMethod: PaymentMethod {
        bacsPaymentMethod
    }

    /// The context object for this component.
    package let context: AdyenContext

    /// Component's configuration
    package var configuration: Configuration

    // MARK: - PaymentComponent

    package func submit() {
        bacsViewModel?.submit()
    }

    // MARK: - Properties

    internal let bacsPaymentMethod: BACSDirectDebitPaymentMethod

    internal private(set) var bacsViewModel: BACSViewModel?

    // MARK: - Initializers

    /// Creates and returns a BACS Direct Debit component.
    /// - Parameters:
    ///   - paymentMethod: The BACS Direct Debit payment method.
    ///   - context: The context object for this component.
    ///   - configuration: Configuration for the component.
    package init(
        paymentMethod: BACSDirectDebitPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.bacsPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }

    // MARK: - Private

    private func createViewController() -> UIViewController {
        let tracker = BACSDirectDebitComponentTracker(
            paymentMethod: bacsPaymentMethod,
            context: context,
            isDropIn: _isDropIn
        )
        let itemsFactory = BACSItemsFactory(
            styleProvider: configuration.style,
            localizationParameters: configuration.localizationParameters,
            scope: String(describing: self)
        )

        let viewModel = BACSViewModel(
            paymentMethod: bacsPaymentMethod,
            amount: context.amount,
            configuration: configuration,
            tracker: tracker,
            itemsFactory: itemsFactory,
            onSubmit: { [weak self] details in
                let data = PaymentComponentData(
                    paymentMethodDetails: details,
                    amount: self?.context.amount,
                    order: self?.order
                )
                self?.submit(data: data)
            }
        )
        self.bacsViewModel = viewModel

        return BACSViewController(
            title: paymentMethod.name,
            viewModel: viewModel
        )
    }
}

// MARK: - LoadingComponent

/// :nodoc:
extension BACSDirectDebitComponent: LoadingComponent {

    /// Stops any processing animation that the component is running.
    package func stopLoading() {
        bacsViewModel?.stopLoading()
    }
}
