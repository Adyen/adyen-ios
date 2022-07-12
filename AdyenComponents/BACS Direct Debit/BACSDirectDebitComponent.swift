//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal protocol BACSDirectDebitRouterProtocol: AnyObject {
    func presentConfirmation(with data: BACSDirectDebitData)
    func confirmPayment(with data: BACSDirectDebitData)
}

/// A component that provides a form for BACS Direct Debit payments.
public final class BACSDirectDebitComponent: PaymentComponent, PaymentAware, PresentableComponent {

    /// Configuration for BACS Direct Debit Component.
    public typealias Configuration = BasicComponentConfiguration
    
    // MARK: - PresentableComponent

    public let viewController: UIViewController

    public var requiresModalPresentation: Bool = true

    /// The object that acts as the delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// The BACS Direct Debit payment method.
    public var paymentMethod: PaymentMethod { bacsPaymentMethod }

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext

    /// The object that acts as the presentation delegate of the component.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// Component's configuration
    public var configuration: Configuration

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
    public init(paymentMethod: BACSDirectDebitPaymentMethod,
                context: AdyenContext,
                configuration: Configuration = .init()) {
        self.bacsPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.inputFormViewController = BACSInputFormViewController(title: paymentMethod.name,
                                                                   styleProvider: configuration.style)
        self.viewController = SecuredViewController(child: inputFormViewController,
                                                    style: configuration.style)
        
        let tracker = BACSDirectDebitComponentTracker(paymentMethod: bacsPaymentMethod,
                                                      apiContext: context.apiContext,
                                                      telemetryTracker: context.analyticsProvider,
                                                      isDropIn: _isDropIn)
        let itemsFactory = BACSItemsFactory(styleProvider: configuration.style,
                                            localizationParameters: configuration.localizationParameters,
                                            scope: String(describing: self))
        self.inputPresenter = BACSInputPresenter(view: inputFormViewController,
                                                 router: self,
                                                 tracker: tracker,
                                                 itemsFactory: itemsFactory)
        inputPresenter?.amount = payment?.amount
        inputFormViewController.presenter = inputPresenter
        
    }
}

// MARK: - BACSDirectDebitRouterProtocol

/// :nodoc:
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
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
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

/// :nodoc:
extension BACSDirectDebitComponent: LoadingComponent {

    /// Stops any processing animation that the component is running.
    public func stopLoading() {
        confirmationPresenter?.stopLoading()
    }
}

// MARK: - Cancellable

/// :nodoc:
extension BACSDirectDebitComponent: Cancellable {

    /// Called when the user cancels the component.
    public func didCancel() {
        if confirmationViewPresented == false {
            inputPresenter?.resetForm()
        } else {
            confirmationViewPresented = false
        }
    }
}
