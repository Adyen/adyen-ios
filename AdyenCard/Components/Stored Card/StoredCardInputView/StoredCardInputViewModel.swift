//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import protocol Adyen.PaymentMethod
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormValueItem
#endif
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import Combine
import Foundation

// sourcery: AutoMockable
internal protocol StoredCardInputViewModelProtocol: AnyObject {
    var securityCodeItem: FormCardSecurityCodeItem { get }

    var submitButtonTitle: String { get }

    @MainActor func submit() async
    @MainActor func viewDidDisappear()

    var theme: CheckoutTheme { get }

    @MainActor var onSecurityCodeValidationRequested: VoidCompletion? { get set }
    var inProgressPublisher: Published<Bool>.Publisher { get }
    func viewDidLoad()
}

internal final class StoredCardInputViewModel: StoredCardInputViewModelProtocol {

    private let localizationParameters: LocalizationParameters?
    private var storedCardPaymentMethod: StoredCardPaymentMethod
    private let analyticsProvider: AnyAnalyticsProvider?
    private let amount: Amount?
    private let publicKey: String
    private let cardBrand: CardBrand

    internal let theme: CheckoutTheme
    internal var onSecurityCodeValidationRequested: VoidCompletion?

    @MainActor @Published internal var inProgress: Bool = false
    internal var inProgressPublisher: Published<Bool>.Publisher {
        $inProgress
    }

    /// This informs the status of the payment after submitting the security code.
    internal var cardDetailsCompletionHandler: Completion<Result<CardDetails, Error>>?

    internal init(
        theme: CheckoutTheme,
        storedCardPaymentMethod: StoredCardPaymentMethod,
        publicKey: String,
        amount: Amount?,
        analyticsProvider: AnyAnalyticsProvider?,
        localizationParameters: LocalizationParameters?,
        cardBrand: CardBrand
    ) {
        self.theme = theme
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.amount = amount
        self.publicKey = publicKey
        self.localizationParameters = localizationParameters
        self.analyticsProvider = analyticsProvider
        self.cardBrand = cardBrand
    }

    internal lazy var securityCodeItem: FormCardSecurityCodeItem = {
        let item = FormCardSecurityCodeItem(localizationParameters: localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItem")
        return item
    }()

    internal var submitButtonTitle: String {
        AmountAwarePaymentStringsPolicy.payButtonTitle(
            with: amount,
            style: .immediate,
            localizationParameters: localizationParameters
        )
    }

    internal func viewDidLoad() {
        sendDidLoadEvent()
        securityCodeItem.selectedCard = cardBrand
    }

    @MainActor internal func viewDidDisappear() {
        resetSecurityCodeField()
        inProgress = false
    }

    // MARK: - Submit payment

    @MainActor internal func submit() async {
        guard securityCodeItem.isValid() else {
            onSecurityCodeValidationRequested?()
            return
        }

        inProgress = true
        let securityCode: String = securityCodeItem.value
        resetSecurityCodeField()
        await submitPayment(securityCode: securityCode)
        // We do not know the result of the submit payment hence we keep the state as in progress.
    }

    internal func submitPayment(securityCode: String) async {
        do {
            let encryptedCardDetails: CardDetails = try {
                do {
                    return try encryptCardDetails(
                        securityCode: securityCode,
                        cardPublicKey: publicKey
                    )
                } catch {
                    sendEncryptionErrorEvent()
                    throw error
                }
            }()
            cardDetailsCompletionHandler?(.success(encryptedCardDetails))
        } catch {
            cardDetailsCompletionHandler?(.failure(error))
        }
    }

    @MainActor internal func resetSecurityCodeField() {
        securityCodeItem.value = ""
    }

    private func encryptCardDetails(
        securityCode: String,
        cardPublicKey: String
    ) throws -> CardDetails {
        let encryptedSecurityCode = try CardEncryptor.encrypt(
            securityCode: securityCode,
            with: cardPublicKey
        )
        return CardDetails(
            paymentMethod: storedCardPaymentMethod,
            encryptedSecurityCode: encryptedSecurityCode
        )
    }

    // MARK: - Events

    private func sendEncryptionErrorEvent() {
        var errorEvent = AnalyticsEventError(
            component: storedCardPaymentMethod.type.rawValue,
            type: .internal
        )
        errorEvent.code = AnalyticsConstants.ErrorCode.encryptionError.stringValue
        analyticsProvider?.add(error: errorEvent)
    }

    private func sendDidLoadEvent() {
        var infoEvent = AnalyticsEventInfo(
            component: storedCardPaymentMethod.type.rawValue,
            type: .rendered
        )
        infoEvent.isStoredPaymentMethod = true
        infoEvent.brand = storedCardPaymentMethod.brand.rawValue
        analyticsProvider?.add(info: infoEvent)
    }
}
