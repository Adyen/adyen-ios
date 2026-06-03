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

internal protocol BACSDirectDebitRouterProtocol: AnyObject {
    func presentConfirmation(with data: BACSDirectDebitData)
    func confirmPayment(with data: BACSDirectDebitData)
}

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
    
    internal var confirmationPresenter: BACSConfirmationPresenterProtocol?
    private var confirmationViewPresented = false
    
    internal let inputFormViewController: BACSInputFormViewController
    
    internal private(set) var inputPresenter: BACSInputPresenterProtocol?
    
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
        self.inputFormViewController = BACSInputFormViewController(
            title: paymentMethod.name,
            scrollEnabled: configuration.showsSubmitButton,
            styleProvider: configuration.style
        )
        self.viewController = SecuredViewController(
            child: inputFormViewController,
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
        self.inputPresenter = BACSInputPresenter(
            view: inputFormViewController,
            router: self,
            tracker: tracker,
            itemsFactory: itemsFactory
        )
        inputPresenter?.amount = context.amount
        inputFormViewController.presenter = inputPresenter
        
    }

    package func submit() {
        // TODO: - Naufal: How to handle submit in BACS?
        // - submit() flow does not fit into a two step component.
        // - Zero traffic on BACS. We either drop support or BACS has to be redesigned into a single step component.
    }
}

// MARK: - BACSDirectDebitRouterProtocol

/// :nodoc:
extension BACSDirectDebitComponent: BACSDirectDebitRouterProtocol {

    internal func presentConfirmation(with data: BACSDirectDebitData) {
        confirmationViewPresented = true
        let confirmationView = assembleConfirmationView(with: data)

        let wrappedComponent = PresentableComponentWrapper(
            component: self,
            viewController: confirmationView
        )
        presentationDelegate?.present(component: wrappedComponent)
    }

    internal func confirmPayment(with data: BACSDirectDebitData) {
        guard let bacsDirectDebitPaymentMethod = paymentMethod as? BACSDirectDebitPaymentMethod else {
            return
        }
        let details = BACSDirectDebitDetails(
            paymentMethod: bacsDirectDebitPaymentMethod,
            holderName: data.holderName,
            bankAccountNumber: data.bankAccountNumber,
            bankLocationId: data.bankLocationId
        )
        confirmationPresenter?.startLoading()
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: context.amount, order: order))
    }

    // MARK: - Private

    private func assembleConfirmationView(with data: BACSDirectDebitData) -> UIViewController {
        let confirmationViewController = BACSConfirmationViewController(
            title: paymentMethod.name,
            scrollEnabled: configuration.showsSubmitButton,
            styleProvider: configuration.style,
            localizationParameters: configuration.localizationParameters
        )
        let itemsFactory = BACSItemsFactory(
            styleProvider: configuration.style,
            localizationParameters: configuration.localizationParameters,
            scope: String(describing: self)
        )
        confirmationPresenter = BACSConfirmationPresenter(
            data: data,
            view: confirmationViewController,
            router: self,
            itemsFactory: itemsFactory
        )
        confirmationViewController.presenter = confirmationPresenter
        return SecuredViewController(child: confirmationViewController, style: configuration.style)
    }
}

// MARK: - LoadingComponent

/// :nodoc:
extension BACSDirectDebitComponent: LoadingComponent {

    /// Stops any processing animation that the component is running.
    package func stopLoading() {
        confirmationPresenter?.stopLoading()
    }
}

// MARK: - Cancellable

/// :nodoc:
extension BACSDirectDebitComponent: Cancellable {

    /// Called when the user cancels the component.
    package func didCancel() {
        if confirmationViewPresented == false {
            inputPresenter?.resetForm()
        } else {
            confirmationViewPresented = false
        }
    }
}
