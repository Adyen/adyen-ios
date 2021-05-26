//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import UIKit

/// A component that provides a form for gift card payments.
public final class GiftCardComponent: PartialPaymentComponent,
    CardPublicKeyConsumer,
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

        /// Indicates that card details encryption failed.
        case cardEncryptionFailed

        /// Indicates any other error
        case otherError(Swift.Error)

        /// :nodoc:
        public var errorDescription: String? {
            switch self {
            case .balanceCheckFailure:
                return "Due to a network issue we couldn’t retrieve the balance. Please try again."
            case .invalidPayment:
                return "For gift card flow to work, you need to provide the Payment object to the component."
            case .missingPartialPaymentDelegate:
                return "Please provide a `PartialPaymentDelegate` object"
            case .cardEncryptionFailed:
                return "Card details encryption failed."
            case let .otherError(error):
                return error.localizedDescription
            }
        }
    }

    /// :nodoc:
    private let giftCardPaymentMethod: GiftCardPaymentMethod

    /// :nodoc:
    internal var cardPublicKeyProvider: AnyCardPublicKeyProvider

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

    /// :nodoc:
    public var clientKey: String? {
        didSet {
            environment.clientKey = clientKey
            cardPublicKeyProvider.clientKey = clientKey
        }
    }

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
        self.cardPublicKeyProvider = CardPublicKeyProvider()
        self.cardPublicKeyProvider.clientKey = clientKey
        self.environment.clientKey = clientKey
    }

    // MARK: - Presentable Component Protocol

    /// :nodoc:
    public lazy var viewController: UIViewController = {
        SecuredViewController(child: formViewController, style: style)
    }()

    /// :nodoc:
    public var requiresModalPresentation: Bool { true }

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self
        formViewController.title = paymentMethod.name
        formViewController.append(errorItem)
        formViewController.append(numberItem)
        formViewController.append(securityCodeItem)
        formViewController.append(button)
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
        hideError()
        guard formViewController.validate() else {
            return
        }

        startLoading()

        fetchCardPublicKey(discardError: false) { [weak self] cardPublicKey in
            guard let self = self else { return }
            let paymentDataResult = self.createPaymentData(order: self.order, cardPublicKey: cardPublicKey)
            paymentDataResult
                .mapError(Error.otherError)
                .handle(success: self.startFlow(with:), failure: self.handle(error:))
        }
    }

    private func startFlow(with paymentData: PaymentComponentData) {
        partialPaymentDelegate?.checkBalance(with: paymentData) { [weak self] result in
            guard let self = self else { return }
            result
                .mapError(Error.otherError)
                .flatMap(self.check(balance:))
                .flatMap { balanceCheckResult in
                    if balanceCheckResult.isBalanceEnough {
                        return self.onReadyToPayFullAmount(remainingAmount: balanceCheckResult.remainingBalanceAmount,
                                                           paymentData: paymentData)
                    } else {
                        let newPaymentData = paymentData.replacingAmount(with: balanceCheckResult.amountToPay)
                        return self.startPartialPaymentFlow(paymentData: newPaymentData)
                    }
                }
                .handle(success: { /* Do nothing.*/ }, failure: { self.handle(error: $0) })
        }
    }

    // MARK: - Error handling

    private func handle(error: Swift.Error) {
        defer {
            stopLoading()
        }
        if case let Error.otherError(internalError) = error {
            delegate?.didFail(with: internalError, from: self)
        }
        guard let error = error as? BalanceChecker.Error else {
            showError(message: localizedString(.errorUnknown, localizationParameters))
            return
        }
        switch error {
        case .unexpectedCurrencyCode:
            showError(message: localizedString(.giftcardCurrencyError, localizationParameters))
        case .zeroBalance:
            showError(message: localizedString(.giftcardNoBalance, localizationParameters))
        }
    }

    // MARK: - Balance check

    private func check(balance: Balance) -> Result<BalanceChecker.Result, Swift.Error> {
        guard let payment = payment else {
            AdyenAssertion.assertionFailure(message: Error.invalidPayment.localizedDescription)
            return .failure(Error.invalidPayment)
        }
        do {
            return .success(try BalanceChecker().check(balance: balance, isEnoughToPay: payment.amount))
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Ready to pay full amount

    private func onReadyToPayFullAmount(remainingAmount: Payment.Amount, paymentData: PaymentComponentData) -> Result<Void, Swift.Error> {
        AdyenAssertion.assert(message: "readyToSubmitComponentDelegate is nil",
                              condition: _isDropIn && readyToSubmitComponentDelegate == nil)
        stopLoading()
        if let readyToSubmitComponentDelegate = readyToSubmitComponentDelegate {
            showConfirmation(delegate: readyToSubmitComponentDelegate,
                             remainingAmount: remainingAmount,
                             paymentData: paymentData)
        } else {
            delegate?.didSubmit(paymentData, from: self)
        }
        return .success(())
    }

    private func showConfirmation(delegate: ReadyToSubmitPaymentComponentDelegate,
                                  remainingAmount: Payment.Amount,
                                  paymentData: PaymentComponentData) {
        let lastFourDigits = String(numberItem.value.suffix(4))
        let footnote = localizedString(.partialPaymentRemainingBalance,
                                       localizationParameters,
                                       remainingAmount.formatted)
        let displayInformation = DisplayInformation(title: String.Adyen.securedString + lastFourDigits,
                                                    subtitle: nil,
                                                    logoName: giftCardPaymentMethod.brand,
                                                    footnoteText: footnote)

        let paymentMethod = CustomDisplayablePaymentMethod(paymentMethod: giftCardPaymentMethod,
                                                           displayInformation: displayInformation)
        let component = InstantPaymentComponent(paymentMethod: paymentMethod, paymentData: paymentData)
        delegate.showConfirmation(for: component)
    }

    // MARK: - Partial Payment flow

    private func startPartialPaymentFlow(paymentData: PaymentComponentData) -> Result<Void, Swift.Error> {
        if let order = order {
            submit(order: order, paymentData: paymentData)
            return .success(())
        }
        guard let partialPaymentDelegate = partialPaymentDelegate else {
            AdyenAssertion.assertionFailure(message: Error.missingPartialPaymentDelegate.localizedDescription)
            return .failure(Error.missingPartialPaymentDelegate)
        }
        partialPaymentDelegate.requestOrder { [weak self] result in
            self?.handle(orderResult: result, paymentData: paymentData)
        }
        return .success(())
    }

    private func handle(orderResult: Result<PartialPaymentOrder, Swift.Error>,
                        paymentData: PaymentComponentData) {
        orderResult.handle(success: {
            submit(order: $0, paymentData: paymentData)
        }, failure: {
            delegate?.didFail(with: $0, from: self)
        })
    }

    // MARK: - Submit payment

    private func submit(order: PartialPaymentOrder, paymentData: PaymentComponentData) {
        self.delegate?.didSubmit(paymentData.replacingOrder(with: order), from: self)
    }

    // MARK: - PaymentData creation

    private func createPaymentData(order: PartialPaymentOrder?, cardPublicKey: String) -> Result<PaymentComponentData, Swift.Error> {
        do {
            let card = Card(number: numberItem.value, securityCode: securityCodeItem.value)
            let encryptedCard = try CardEncryptor.encrypt(card: card, with: cardPublicKey)

            guard let number = encryptedCard.number,
                  let securityCode = encryptedCard.securityCode else { throw Error.cardEncryptionFailed }

            let details = GiftCardDetails(paymentMethod: giftCardPaymentMethod,
                                          encryptedCardNumber: number,
                                          encryptedSecurityCode: securityCode)

            return .success(PaymentComponentData(paymentMethodDetails: details,
                                                 amount: payment?.amount,
                                                 order: order,
                                                 storePaymentMethod: false))
        } catch {
            return .failure(error)
        }
    }
}

/// :nodoc:
public extension Result {
    /// :nodoc:
    func handle(success: (Success) -> Void, failure: (Failure) -> Void) {
        switch self {
        case let .success(successObject):
            success(successObject)
        case let .failure(error):
            failure(error)
        }
    }
}

/// :nodoc:
extension GiftCardComponent: TrackableComponent {
    /// :nodoc:
    public func viewDidLoad(viewController: UIViewController) {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        fetchCardPublicKey(discardError: true) { _ in /* Do nothing, to just cache the card public key value */ }
    }
}
