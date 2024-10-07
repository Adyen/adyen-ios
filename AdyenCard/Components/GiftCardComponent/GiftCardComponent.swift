//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import UIKit

/// A component that provides a form for gift card payments.
public final class GiftCardComponent: PresentableComponent,
    Localizable,
    LoadingComponent,
    AdyenObserver {

    internal let amount: Amount
    
    internal enum PartialPaymentMethodType {
        case giftCard(GiftCardPaymentMethod)
        case mealVoucher(MealVoucherPaymentMethod)
        
        internal var partialPaymentMethod: PartialPaymentMethod {
            switch self {
            case let .giftCard(giftCardPaymentMethod):
                return giftCardPaymentMethod
            case let .mealVoucher(mealVoucherPaymentMethod):
                return mealVoucherPaymentMethod
            }
        }
    }
    
    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext
    
    private let partialPaymentMethodType: PartialPaymentMethodType

    @_spi(AdyenInternal)
    public let publicKeyProvider: AnyPublicKeyProvider

    /// The gift card payment method.
    public var paymentMethod: PaymentMethod { partialPaymentMethodType.partialPaymentMethod }

    /// Describes the component's UI style.
    public let style: FormComponentStyle

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// The partial payment component delegate.
    public weak var partialPaymentDelegate: PartialPaymentDelegate?

    /// The delegate that handles shopper confirmation UI when the balance of the gift card is sufficient to pay.
    public weak var readyToSubmitComponentDelegate: ReadyToSubmitPaymentComponentDelegate?

    /// The localization parameters.
    public var localizationParameters: LocalizationParameters?

    /// Indicates whether to show the security code field at all.
    internal let showsSecurityCodeField: Bool

    /// Initializes the partial payment component with a gift card payment method.
    ///
    /// - Parameters:
    ///   - paymentMethod: The gift card payment method.
    ///   - context:The context object for this component.
    ///   - amount: The amount to pay.
    ///   - style: The Component's UI style.
    ///   - showsSecurityCodeField: Indicates whether to show the security code field at all.
    public convenience init(
        paymentMethod: GiftCardPaymentMethod,
        context: AdyenContext,
        amount: Amount,
        style: FormComponentStyle = FormComponentStyle(),
        showsSecurityCodeField: Bool = true
    ) {
        self.init(
            partialPaymentMethodType: .giftCard(paymentMethod),
            context: context,
            amount: amount,
            style: style,
            showsSecurityCodeField: showsSecurityCodeField,
            publicKeyProvider: PublicKeyProvider(apiContext: context.apiContext)
        )
    }
    
    /// Initializes the partial payment component with a Meal Voucher payment method.
    ///
    /// - Parameters:
    ///   - paymentMethod: The meal voucher payment method.
    ///   - context:The context object for this component.
    ///   - amount: The amount to pay.
    ///   - style: The Component's UI style.
    ///   - showsSecurityCodeField: Indicates whether to show the security code field at all.
    public convenience init(
        paymentMethod: MealVoucherPaymentMethod,
        context: AdyenContext,
        amount: Amount,
        style: FormComponentStyle = FormComponentStyle(),
        showsSecurityCodeField: Bool = true
    ) {
        self.init(
            partialPaymentMethodType: .mealVoucher(paymentMethod),
            context: context,
            amount: amount,
            style: style,
            showsSecurityCodeField: showsSecurityCodeField,
            publicKeyProvider: PublicKeyProvider(apiContext: context.apiContext)
        )
    }
    
    internal init(
        partialPaymentMethodType: PartialPaymentMethodType,
        context: AdyenContext,
        amount: Amount,
        style: FormComponentStyle = FormComponentStyle(),
        showsSecurityCodeField: Bool = true,
        publicKeyProvider: AnyPublicKeyProvider
    ) {
        self.partialPaymentMethodType = partialPaymentMethodType
        self.context = context
        self.style = style
        self.showsSecurityCodeField = showsSecurityCodeField
        self.publicKeyProvider = publicKeyProvider
        self.amount = amount
    }

    // MARK: - Presentable Component Protocol

    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController, style: style)

    public var requiresModalPresentation: Bool { true }

    private lazy var formViewController: FormViewController = {

        let formViewController = FormViewController(
            style: style,
            localizationParameters: localizationParameters
        )
        formViewController.delegate = self
        formViewController.title = partialPaymentMethodType.partialPaymentMethod.displayInformation(using: localizationParameters).title
        formViewController.append(errorItem)
        formViewController.append(numberItem)

        switch (partialPaymentMethodType, showsSecurityCodeField) {
        case (.giftCard, true):
            formViewController.append(securityCodeItem)
        case (.giftCard, false):
            break // Nothing additionally to add
        case (.mealVoucher, true):
            let splitTextItem = FormSplitItem(
                items: expiryDateItem,
                securityCodeItem,
                style: style.textField
            )
            formViewController.append(splitTextItem)
        case (.mealVoucher, false):
            formViewController.append(expiryDateItem)
        }
        
        formViewController.append(FormSpacerItem())
        formViewController.append(button)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        return formViewController
    }()

    // MARK: Items

    internal lazy var errorItem: FormErrorItem = {
        let item = FormErrorItem(style: style.errorStyle)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "errorItem")
        return item
    }()

    internal lazy var numberItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        item.title = localizedString(.cardNumberItemTitle, localizationParameters)
        item.validator = NumericStringValidator(minimumLength: 15, maximumLength: 32)
        item.formatter = CardNumberFormatter()
        item.placeholder = localizedString(.cardNumberItemPlaceholder, localizationParameters)
        item.validationFailureMessage = localizedString(.cardNumberItemInvalid, localizationParameters)
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "numberItem")
        return item
    }()

    internal lazy var securityCodeItem: FormTextInputItem = {
        let item = FormTextInputItem(style: style.textField)
        let title: String
        switch partialPaymentMethodType {
        case .giftCard:
            title = localizedString(.cardPinTitle, localizationParameters)
        case .mealVoucher:
            title = localizedString(.cardCvcItemTitle, localizationParameters)
        }
        item.title = title
        item.validator = NumericStringValidator(minimumLength: 3, maximumLength: 10)
        item.formatter = NumericFormatter()
        item.placeholder = localizedString(.cardCvcItemPlaceholder, localizationParameters)

        item.validationFailureMessage = localizedString(.missingField, localizationParameters)
        item.keyboardType = .numberPad
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItem")
        return item
    }()
    
    internal lazy var expiryDateItem: FormCardExpiryDateItem = {
        let expiryDateItem = FormCardExpiryDateItem(
            style: style.textField,
            localizationParameters: localizationParameters
        )
        expiryDateItem.localizationParameters = localizationParameters
        expiryDateItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "expiryDateItem")

        return expiryDateItem
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

    // MARK: - Loading Component Protocol

    public func stopLoading() {
        button.showsActivityIndicator = false
        viewController.view.isUserInteractionEnabled = true
    }

    internal func startLoading() {
        button.showsActivityIndicator = true
        viewController.view.isUserInteractionEnabled = false
    }

    private func showError(message: String) {
        errorItem.message = message
        errorItem.isHidden.wrappedValue = false
        UIAccessibility.post(notification: .announcement, argument: "\(localizedString(.errorTitle, localizationParameters)): \(message)")
    }

    private func hideError() {
        errorItem.message = nil
        errorItem.isHidden.wrappedValue = true
    }
}

// MARK: Flow functions

extension GiftCardComponent {
    
    internal func didSelectSubmitButton() {
        hideError()
        guard formViewController.validate() else {
            return
        }

        startLoading()

        fetchCardPublicKey(notifyingDelegateOnFailure: true) { [weak self] cardPublicKey in
            guard let self else { return }
            self.createPaymentData(
                order: self.order,
                cardPublicKey: cardPublicKey
            )
            .mapError(Error.otherError)
            .handle(success: self.startFlow(with:), failure: self.handle(error:))
        }
    }

    private func startFlow(with paymentData: PaymentComponentData) {
        partialPaymentDelegate?.checkBalance(with: paymentData, component: self) { [weak self] result in
            guard let self else { return }
            result
                .mapError { error in
                    if error is BalanceChecker.Error {
                        return error
                    } else {
                        return Error.otherError(error)
                    }
                }
                .flatMap {
                    self.check(balance: $0, toPay: self.amount)
                }
                .flatMap { balanceCheckResult in
                    if balanceCheckResult.isBalanceEnough {
                        return self.onReadyToPayFullAmount(
                            remainingAmount: balanceCheckResult.remainingBalanceAmount,
                            paymentData: paymentData
                        )
                    } else {
                        let newPaymentData = paymentData.replacing(amount: balanceCheckResult.amountToPay)
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

    private func check(balance: Balance, toPay amount: Amount) -> Result<BalanceChecker.Result, Swift.Error> {
        do {
            return try .success(BalanceChecker().check(balance: balance, isEnoughToPay: amount))
        } catch {
            return .failure(error)
        }
    }

    // MARK: - Ready to pay full amount

    private func onReadyToPayFullAmount(remainingAmount: Amount, paymentData: PaymentComponentData) -> Result<Void, Swift.Error> {
        AdyenAssertion.assert(
            message: "readyToSubmitComponentDelegate is nil",
            condition: _isDropIn && readyToSubmitComponentDelegate == nil
        )
        stopLoading()
        if let readyToSubmitComponentDelegate {
            showConfirmation(
                delegate: readyToSubmitComponentDelegate,
                remainingAmount: remainingAmount,
                paymentData: paymentData
            )
        } else {
            submit(data: paymentData, component: self)
        }
        return .success(())
    }

    private func showConfirmation(
        delegate: ReadyToSubmitPaymentComponentDelegate,
        remainingAmount: Amount,
        paymentData: PaymentComponentData
    ) {
        let lastFourDigits = String(numberItem.value.suffix(4))

        let paymentMethod = PartialConfirmationPaymentMethod(
            paymentMethod: partialPaymentMethodType.partialPaymentMethod,
            lastFour: lastFourDigits,
            remainingAmount: remainingAmount
        )
        
        let component = InstantPaymentComponent(
            paymentMethod: paymentMethod,
            context: context,
            paymentData: paymentData
        )
        delegate.showConfirmation(for: component, with: paymentData.order)
    }

    // MARK: - Partial Payment flow

    private func startPartialPaymentFlow(paymentData: PaymentComponentData) -> Result<Void, Swift.Error> {
        if let order {
            submit(order: order, paymentData: paymentData)
            return .success(())
        }
        guard let partialPaymentDelegate else {
            AdyenAssertion.assertionFailure(message: Error.missingPartialPaymentDelegate.localizedDescription)
            return .failure(Error.missingPartialPaymentDelegate)
        }
        partialPaymentDelegate.requestOrder(for: self) { [weak self] result in
            self?.handle(orderResult: result, paymentData: paymentData)
        }
        return .success(())
    }

    private func handle(
        orderResult: Result<PartialPaymentOrder, Swift.Error>,
        paymentData: PaymentComponentData
    ) {
        orderResult
            .mapError(Error.otherError)
            .handle(success: {
                submit(order: $0, paymentData: paymentData)
            }, failure: handle(error:))
    }

    // MARK: - Submit payment

    private func submit(order: PartialPaymentOrder, paymentData: PaymentComponentData) {
        submit(data: paymentData.replacing(order: order), component: self)
    }

    // MARK: - PaymentData creation

    private func createPaymentData(order: PartialPaymentOrder?, cardPublicKey: String) -> Result<PaymentComponentData, Swift.Error> {
        do {
            let card = Card(
                number: numberItem.value,
                securityCode: securityCodeItem.value,
                expiryMonth: expiryDateItem.expiryMonth,
                expiryYear: expiryDateItem.expiryYear
            )
            let encryptedCard = try CardEncryptor.encrypt(card: card, with: cardPublicKey)
            
            let details: PartialPaymentMethodDetails
            
            switch partialPaymentMethodType {
            case let .giftCard(giftCardPaymentMethod):
                details = try GiftCardDetails(
                    paymentMethod: giftCardPaymentMethod,
                    encryptedCard: encryptedCard
                )
            case let .mealVoucher(mealVoucherPaymentMethod):
                details = try MealVoucherDetails(
                    paymentMethod: mealVoucherPaymentMethod,
                    encryptedCard: encryptedCard
                )
            }

            return .success(PaymentComponentData(
                paymentMethodDetails: details,
                amount: amount,
                order: order,
                storePaymentMethod: false
            ))
        } catch {
            return .failure(error)
        }
    }
}

@_spi(AdyenInternal)
extension GiftCardComponent: PaymentComponent {}

@_spi(AdyenInternal)
extension GiftCardComponent: PartialPaymentComponent {}

@_spi(AdyenInternal)
extension GiftCardComponent: PublicKeyConsumer {}
