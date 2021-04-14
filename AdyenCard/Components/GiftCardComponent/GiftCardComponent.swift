//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that provides a form for gift card payments.
public final class GiftCardComponent: PartialPaymentComponent,
    PaymentComponent,
    PresentableComponent,
    Localizable,
    LoadingComponent,
    Observer {

    /// Indicates Gift card related errors.
    public enum Error: LocalizedError {

        /// Indicates that the balance check failed for some reason.
        case balanceCheckFailure

        /// Indicates the payment object passed to the `GiftCardComponent` is nil or invalid.
        case invalidPayment

        /// Indicates that the `partialPaymentDelegate` is nil.
        case missingPartialPaymentDelegate

        /// Indicates any other error
        case otherError(Swift.Error)

        public var errorDescription: String? {
            switch self {
            case .balanceCheckFailure:
                return "Due to a network issue we couldn’t retrieve the balance. Please try again."
            case .invalidPayment:
                return "For gift card flow to work, you need to provide the Payment object to the component."
            case .missingPartialPaymentDelegate:
                return "Please provide a `PartialPaymentDelegate` object"
            case let .otherError(error):
                return error.localizedDescription
            }
        }
    }

    /// :nodoc:
    private let giftCardPaymentMethod: GiftCardPaymentMethod

    /// The gift card payment method.
    public var paymentMethod: PaymentMethod { giftCardPaymentMethod }

    /// Describes the component's UI style.
    public let style: FormComponentStyle

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// The partial payment component delegate.
    public weak var partialPaymentDelegate: PartialPaymentDelegate?

    /// The delegate that handles shopper confirmation UI when the balance of the gift card is sufficient to pay.
    public weak var readyToSubmitComponentDelegate: ReadyToSubmitPaymentComponentDelegate?

    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The gift card payment method.
    ///   -  clientKey: The client key that corresponds to the webservice user you will use for initiating the payment.
    /// See https://docs.adyen.com/user-management/client-side-authentication for more information.
    ///   -  style: The Component's UI style.
    public init(paymentMethod: GiftCardPaymentMethod,
                clientKey: String,
                style: FormComponentStyle = FormComponentStyle()) {
        self.giftCardPaymentMethod = paymentMethod
        self.style = style
        self.environment.clientKey = clientKey
    }

    // MARK: - Presentable Component Protocol

    /// :nodoc:
    public var viewController: UIViewController { securedViewController }

    /// :nodoc:
    public var requiresModalPresentation: Bool { true }

    private lazy var securedViewController = SecuredViewController(child: formViewController, style: style)

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self
        formViewController.title = paymentMethod.name
        formViewController.append(errorItem)
        formViewController.append(numberItem)
        formViewController.append(securityCodeItem)
        formViewController.append(button.withPadding(padding: .init(top: 8, left: 0, bottom: -16, right: 0)))
        return formViewController
    }()

    // MARK: Items

    internal lazy var errorItem: FormErrorItem = {
        let item = FormErrorItem(iconName: "error",
                                 style: style.errorStyle)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "errorItem")
        return item
    }()

    internal lazy var numberItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)

        item.title = localizedString(.cardNumberItemTitle, localizationParameters)
        item.validator = NumericStringValidator(minimumLength: 16)
        item.formatter = CardNumberFormatter()
        item.placeholder = localizedString(.cardNumberItemPlaceholder, localizationParameters)
        item.validationFailureMessage = localizedString(.cardNumberItemInvalid, localizationParameters)
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "numberItem")
        return item
    }()

    internal lazy var securityCodeItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(.cardPinTitle, localizationParameters)
        item.validator = NumericStringValidator(minimumLength: 3)
        item.formatter = NumericFormatter()
        item.placeholder = localizedString(.cardCvcItemPlaceholder, localizationParameters)

        item.validationFailureMessage = localizedString(.missingField, localizationParameters)
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItem")
        return item
    }()

    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = localizedString(.cardApplyGiftcard, localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

    // MARK: - Localizable Protocol

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    // MARK: - Loading Component Protocol

    /// :nodoc:
    public func stopLoading() {
        button.showsActivityIndicator = false
        viewController.view.isUserInteractionEnabled = true
    }

    /// :nodoc:
    internal func startLoading() {
        button.showsActivityIndicator = true
        viewController.view.isUserInteractionEnabled = false
    }

    private func showError(message: String) {
        errorItem.message = message
        errorItem.isHidden.wrappedValue = false
    }

    private func hideError() {
        errorItem.message = nil
        errorItem.isHidden.wrappedValue = true
    }

    // MARK: - Submitting the form

    internal func didSelectSubmitButton() {
        guard formViewController.validate() else {
            return
        }

        startLoading()

        let data = createPaymentData()

        partialPaymentDelegate?.checkBalance(data, from: self) { [weak self] result in
            guard let self = self else { return }
            result
                .mapError(Error.otherError)
                .flatMap(self.check(balance:))
                .flatMap { isBalanceEnough in isBalanceEnough ? self.onReadyToPayFullAmount() : self.requestOrder() }
                .handleError { self.handle(error: $0) }
                .handleSuccess { /* Do nothing.*/ }
        }
    }

    private func handle(error: Swift.Error) {
        if case let Error.otherError(internalError) = error {
            delegate?.didFail(with: internalError, from: self)
        }
        guard let error = error as? BalanceValidator.Error else {
            showError(message: "An unknown error occurred")
            return
        }
        switch error {
        case .unexpectedCurrencyCode:
            showError(message: "Gift cards are only valid in the currency they were issued in")
        case .zeroBalance:
            showError(message: "This gift card has zero balance")
        }
    }

    private func check(balance: Balance) -> Result<Bool, Swift.Error> {
        guard let payment = payment else {
            AdyenAssertion.assert(message: Error.invalidPayment.localizedDescription)
            return .failure(Error.invalidPayment)
        }
        do {
            return .success(try BalanceValidator().validate(balance: balance, toPay: payment.amount))
        } catch {
            return .failure(error)
        }
    }

    private func onReadyToPayFullAmount() -> Result<Void, Swift.Error> {
        AdyenAssertion.assert(message: "readyToSubmitComponentDelegate is nil",
                              condition: !_isDropIn || readyToSubmitComponentDelegate != nil)
        stopLoading()
        if let readyToSubmitComponentDelegate = readyToSubmitComponentDelegate {
            showConfirmation(delegate: readyToSubmitComponentDelegate)
        } else {
            let paymentData = createPaymentData()
            delegate?.didSubmit(paymentData, from: self)
        }
        return .success(())
    }

    private func showConfirmation(delegate: ReadyToSubmitPaymentComponentDelegate) {
        let paymentData = createPaymentData()
        let lastFourDigits = String(numberItem.value.suffix(4))
        let displayInformation = DisplayInformation(title: "••••\u{00a0}" + lastFourDigits,
                                                    subtitle: nil,
                                                    logoName: giftCardPaymentMethod.brand)

        let paymentMethod = PreselectedPaymentMethod(paymentMethod: giftCardPaymentMethod,
                                                     displayInformation: displayInformation)
        let component = ReadyToSubmitPaymentComponent(paymentData: paymentData, paymentMethod: paymentMethod)
        delegate.showConfirmation(for: component)
    }

    private func requestOrder() -> Result<Void, Swift.Error> {
        guard let partialPaymentDelegate = partialPaymentDelegate else {
            AdyenAssertion.assert(message: Error.missingPartialPaymentDelegate.localizedDescription)
            return .failure(Error.missingPartialPaymentDelegate)
        }
        let data = createPaymentData()
        partialPaymentDelegate.requestOrder(data, from: self) { [weak self] result in
            self?.handle(orderResult: result)
        }
        return .success(())
    }

    private func handle(orderResult: Result<PartialPaymentOrder, Swift.Error>) {
        orderResult.handleError { delegate?.didFail(with: $0, from: self) }.handleSuccess(submit(order:))
    }

    private func submit(order: PartialPaymentOrder) {
        delegate?.didSubmit(createPaymentData(order: order), from: self)
    }

    private func createPaymentData(order: PartialPaymentOrder? = nil) -> PaymentComponentData {
        let details = GiftCardDetails(paymentMethod: giftCardPaymentMethod,
                                      cardNumber: numberItem.value,
                                      securityCode: securityCodeItem.value)

        return PaymentComponentData(paymentMethodDetails: details,
                                    amount: payment?.amount,
                                    order: order,
                                    storePaymentMethod: false)
    }
}

extension Result {

    @discardableResult
    func handleSuccess(_ handler: (Success) -> Void) -> Result<Success, Failure> {
        switch self {
        case let .success(success):
            handler(success)
        default: ()
        }
        return self
    }

    @discardableResult
    func handleError(_ handler: (Error) -> Void) -> Result<Success, Failure> {
        switch self {
        case let .failure(error):
            handler(error)
        default: ()
        }
        return self
    }
}

/// :nodoc:
extension GiftCardComponent: TrackableComponent {}
