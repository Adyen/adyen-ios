//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// :nodoc:
internal protocol BACSDirectDebitRouterProtocol: AnyObject {
    func presentConfirmation(with data: BACSDirectDebitData)
    func confirmPayment(with data: BACSDirectDebitData)
}

/// A component that provides a form for BACS Direct Debit payments.
public final class BACSDirectDebitComponent: PaymentComponent, PresentableComponent {

    // MARK: - PresentableComponent

    /// :nodoc:
    public var viewController: UIViewController

    /// :nodoc:
    public var requiresModalPresentation: Bool = true

    /// The object that acts as the delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// The BACS Direct Debit payment method.
    public let paymentMethod: PaymentMethod

    /// :nodoc:
    public let apiContext: APIContext

    /// :nodoc:
    public let style: FormComponentStyle

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    /// The object that acts as the presentation delegate of the component.
    public weak var presentationDelegate: PresentationDelegate?

    // MARK: - Properties

    internal var inputPresenter: BACSInputPresenterProtocol?
    internal var confirmationPresenter: BACSConfirmationPresenterProtocol?
    private var confirmationViewPresented = false

    // MARK: - Initializers

    /// Creates and returns a BACS Direct Debit component.
    /// - Parameters:
    ///   - paymentMethod: The BACS Direct Debit payment method.
    ///   - apiContext: The API context.
    ///   - style: The component's UI style.
    ///   - localizationParameters: The localization parameters.
    public init(paymentMethod: BACSDirectDebitPaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle = .init(),
                localizationParameters: LocalizationParameters? = nil,
                configuration: Configuration? = nil) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.style = style
        self.localizationParameters = localizationParameters

        let inputFormViewController = BACSInputFormViewController(title: paymentMethod.name,
                                                                  styleProvider: style)
        self.viewController = SecuredViewController(child: inputFormViewController, style: style)

        let tracker = BACSDirectDebitComponentTracker(paymentMethod: paymentMethod,
                                                      apiContext: apiContext,
                                                      isDropIn: _isDropIn)
        let itemsFactory = BACSItemsFactory(styleProvider: style,
                                            localizationParameters: localizationParameters,
                                            scope: String(describing: self))
        self.inputPresenter = BACSInputPresenter(view: inputFormViewController,
                                                 router: self,
                                                 tracker: tracker,
                                                 itemsFactory: itemsFactory,
                                                 amount: configuration?.payment.amount)
        inputFormViewController.presenter = inputPresenter
    }
}

// MARK: - BACSDirectDebitRouterProtocol

extension BACSDirectDebitComponent: BACSDirectDebitRouterProtocol {

    internal func presentConfirmation(with data: BACSDirectDebitData) {
        confirmationViewPresented = true
        let confirmationView = assembleConfirmationView(with: data)

        let wrappedComponent = PresentableComponentWrapper(component: self,
                                                           viewController: confirmationView)
        presentationDelegate?.present(component: wrappedComponent)
    }

    internal func confirmPayment(with data: BACSDirectDebitData) {
        guard let bacsDirectDebitPaymentMethod = paymentMethod as? BACSDirectDebitPaymentMethod else {
            return
        }
        let details = BACSDirectDebitDetails(paymentMethod: bacsDirectDebitPaymentMethod,
                                             holderName: data.holderName,
                                             bankAccountNumber: data.bankAccountNumber,
                                             bankLocationId: data.bankLocationId)
        confirmationPresenter?.startLoading()
        let data = PaymentComponentData(paymentMethodDetails: details,
                                        amount: payment?.amount,
                                        order: order)
        submit(data: data)
    }

    // MARK: - Private

    private func assembleConfirmationView(with data: BACSDirectDebitData) -> UIViewController {
        let confirmationViewController = BACSConfirmationViewController(title: paymentMethod.name,
                                                                        styleProvider: style,
                                                                        localizationParameters: localizationParameters)
        let itemsFactory = BACSItemsFactory(styleProvider: style,
                                            localizationParameters: localizationParameters,
                                            scope: String(describing: self))
        confirmationPresenter = BACSConfirmationPresenter(data: data,
                                                          view: confirmationViewController,
                                                          router: self,
                                                          itemsFactory: itemsFactory)
        confirmationViewController.presenter = confirmationPresenter
        return SecuredViewController(child: confirmationViewController, style: style)
    }
}

// MARK: - LoadingComponent

extension BACSDirectDebitComponent: LoadingComponent {

    /// :nodoc:
    /// Stops any processing animation that the component is running.
    public func stopLoading() {
        confirmationPresenter?.stopLoading()
    }
}

// MARK: - Cancellable

extension BACSDirectDebitComponent: Cancellable {

    /// :nodoc:
    /// Called when the user cancels the component.
    public func didCancel() {
        if !confirmationViewPresented {
            inputPresenter?.resetForm()
        } else {
            confirmationViewPresented = false
        }
    }
}

extension BACSDirectDebitComponent {

    /// BACS Direct Debit configuration object.
    public struct Configuration {

        // MARK: - Properties

        /// :nodoc:
        internal let payment: Payment

        // MARK: - Initializers

        /// Creates a BACS Direct Debit configuration with the specified payment.
        /// - Parameter payment: The payment to be made.
        public init(payment: Payment) {
            self.payment = payment
        }
    }
}
