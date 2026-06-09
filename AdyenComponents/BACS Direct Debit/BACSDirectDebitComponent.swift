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

    package let viewController: UIViewController

    /// The object that acts as the delegate of the component.
    package weak var delegate: PaymentComponentDelegate?

    /// The BACS Direct Debit payment method.
    package var paymentMethod: PaymentMethod {
        bacsPaymentMethod
    }

    /// The context object for this component.
    package let context: AdyenContext

    /// The object that acts as the presentation delegate of the component.
    package weak var presentationDelegate: PresentationDelegate?

    /// Component's configuration
    package var configuration: Configuration

    // MARK: - Properties

    internal let bacsPaymentMethod: BACSDirectDebitPaymentMethod

    internal let bacsViewController: BACSViewController
    internal private(set) var bacsViewModel: BACSViewModelProtocol?
    
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
        self.bacsViewController = BACSViewController(
            title: paymentMethod.name,
            scrollEnabled: configuration.showsSubmitButton,
            styleProvider: configuration.style
        )
        self.viewController = SecuredViewController(
            child: bacsViewController,
            style: configuration.style
        )
        
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

        self.bacsViewModel = BACSViewModel(
            view: bacsViewController,
            tracker: tracker,
            itemsFactory: itemsFactory,
            amount: context.amount,
            onSubmitTap: { [weak self] data in
                let details = BACSDirectDebitDetails(
                    paymentMethod: paymentMethod,
                    holderName: data.holderName,
                    bankAccountNumber: data.bankAccountNumber,
                    bankLocationId: data.bankLocationId
                )
                let data = PaymentComponentData(
                    paymentMethodDetails: details,
                    amount: context.amount,
                    order: self?.order
                )
                self?.submit(data: data)
            }
        )
        bacsViewController.viewModel = bacsViewModel
    }

    package func submit() {
        bacsViewModel?.onSubmitButtonTap()
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
