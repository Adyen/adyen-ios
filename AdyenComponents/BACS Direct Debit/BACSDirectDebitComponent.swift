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

    /// Configuration for BACS Direct Debit Component.
    public typealias Configuration = BasicComponentConfiguration
    
    // MARK: - PresentableComponent

    /// :nodoc:
    public var viewController: UIViewController {
        SecuredViewController(child: inputFormViewController, style: configuration.style)
    }

    /// :nodoc:
    public var requiresModalPresentation: Bool = true

    /// The object that acts as the delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// The BACS Direct Debit payment method.
    public var paymentMethod: PaymentMethod { bacsPaymentMethod }

    /// :nodoc:
    public let apiContext: APIContext

    /// The object that acts as the presentation delegate of the component.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// Component's configuration
    public var configuration: Configuration
    
    /// The payment information.
    public var payment: Payment? {
        didSet {
            inputPresenter?.amount = payment?.amount
        }
    }

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
    ///   - apiContext: The API context.
    ///   - configuration: Configuration for the component.
    public init(paymentMethod: BACSDirectDebitPaymentMethod,
                apiContext: APIContext,
                configuration: Configuration = Configuration()) {
        self.bacsPaymentMethod = paymentMethod
        self.apiContext = apiContext
        self.configuration = configuration
        self.inputFormViewController = BACSInputFormViewController(
            title: paymentMethod.name,
            styleProvider: configuration.style
        )
        let tracker = BACSDirectDebitComponentTracker(paymentMethod: bacsPaymentMethod,
                                                      apiContext: apiContext,
                                                      isDropIn: _isDropIn)
        let itemsFactory = BACSItemsFactory(styleProvider: configuration.style,
                                            localizationParameters: configuration.localizationParameters,
                                            scope: String(describing: self))
        self.inputPresenter = BACSInputPresenter(view: inputFormViewController,
                                                 router: self,
                                                 tracker: tracker,
                                                 itemsFactory: itemsFactory)
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
                                        amount: amountToPay,
                                        order: order)
        submit(data: data)
    }

    // MARK: - Private

    private func assembleConfirmationView(with data: BACSDirectDebitData) -> UIViewController {
        let confirmationViewController = BACSConfirmationViewController(title: paymentMethod.name,
                                                                        styleProvider: configuration.style,
                                                                        localizationParameters: configuration.localizationParameters)
        let itemsFactory = BACSItemsFactory(styleProvider: configuration.style,
                                            localizationParameters: configuration.localizationParameters,
                                            scope: String(describing: self))
        confirmationPresenter = BACSConfirmationPresenter(data: data,
                                                          view: confirmationViewController,
                                                          router: self,
                                                          itemsFactory: itemsFactory)
        confirmationViewController.presenter = confirmationPresenter
        return SecuredViewController(child: confirmationViewController, style: configuration.style)
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
        if confirmationViewPresented == false {
            inputPresenter?.resetForm()
        } else {
            confirmationViewPresented = false
        }
    }
}
