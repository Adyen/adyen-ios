//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif

internal protocol StoredCardInputViewModelProtocol: AnyObject {
    var cardImageItem: CardImageItem { get }
    var titleText: String { get }
    var subtitleText: String { get }

    var securityCodeItem: FormCardSecurityCodeItem { get }

    var inputFieldTitle: String { get }
    var inputFieldSubTitle: String { get }

    var submitButtonTitle: String { get }
    func submitPayment() async

    func returnToPreviousScreen()

    var theme: AdyenTheme { get }

    var setPayButtonEnabled: ((Bool) -> Void)? { get set }
}

internal final class StoredCardInputViewModel: StoredCardInputViewModelProtocol {
    private enum Constants {
        static let cardImageSize = CGSize(width: 80, height: 52)
    }

    internal let theme: AdyenTheme
    private let localizationParameters: LocalizationParameters?
    private let paymentMethod: StoredCardPaymentMethod
    private let apiContext: APIContext
    private let analyticsProvider: AnyAnalyticsProvider?

    internal var setPayButtonEnabled: ((Bool) -> Void)?

    /// This informs the status of the payment after submitting the security code.
    internal var cardDetailsCompletionHandler: Completion<Result<CardDetails, Error>>?
    internal var publicKeyProvider: AnyPublicKeyProvider

    internal init(
        theme: AdyenTheme,
        paymentMethod: StoredCardPaymentMethod,
        apiContext: APIContext,
        analyticsProvider: AnyAnalyticsProvider?,
        localizationParameters: LocalizationParameters?
    ) {
        self.theme = theme
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.localizationParameters = localizationParameters
        self.analyticsProvider = analyticsProvider
        self.publicKeyProvider = PublicKeyProvider(apiContext: apiContext)

        securityCodeItem.publisher.addEventHandler { [weak self] value in
            guard let self else { return }
            setPayButtonEnabled?(securityCodeItem.isValid())
        }
    }

    internal lazy var cardImageItem: AdyenUI.CardImageItem = {
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        // TODO: Robert: This will change as we will not rely on DisplayInformation for V6.
        let imageURL = LogoURLProvider.logoURL(
            withName: displayInformation.logoName,
            environment: apiContext.environment,
            size: .large
        )
        return CardImageItem(
            imageURL: imageURL,
            sizeMode: .fixed(Constants.cardImageSize),
            theme: theme
        )
    }()

    internal lazy var securityCodeItem: FormCardSecurityCodeItem = {
        let item = FormCardSecurityCodeItem()
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItem")
        return item
    }()

    internal var titleText: String {
        "Enter security code"
    }

    internal var subtitleText: String {
        "Enter the security code for Visa *** to complete the payment of $140"
    }

    internal var inputFieldTitle: String {
        "Security Code"
    }

    internal var inputFieldSubTitle: String {
        "3 digits, back of card"
    }

    internal var submitButtonTitle: String {
        "Pay 140"
    }

    internal func returnToPreviousScreen() {}

    internal func resetSecurityCodeField() {
        securityCodeItem.value = ""
    }

    @MainActor
    internal func submitPayment() async {
        do {
            let securityCode: String = securityCodeItem.value
            let publicKey = try await fetchCardPublicKey()
            resetSecurityCodeField()
            let encryptedCardDetails: CardDetails = try {
                do {
                    return try encryptCardDetails(securityCode: securityCode, cardPublicKey: publicKey)
                } catch {
                    sendEncryptionErrorEvent()
                    throw error
                }
            }()
            Task { @MainActor in
                cardDetailsCompletionHandler?(.success(encryptedCardDetails))
            }
        } catch {
            Task { @MainActor in
                cardDetailsCompletionHandler?(.failure(error))
            }
        }
    }

    private func fetchCardPublicKey() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            publicKeyProvider.fetch { result in
                continuation.resume(with: result)
            }
        }
    }

    private func encryptCardDetails(securityCode: String, cardPublicKey: String) throws -> CardDetails {
        let encryptedSecurityCode = try CardEncryptor.encrypt(securityCode: securityCode, with: cardPublicKey)
        return CardDetails(paymentMethod: paymentMethod, encryptedSecurityCode: encryptedSecurityCode)
    }

    private func sendEncryptionErrorEvent() {
        var errorEvent = AnalyticsEventError(
            component: paymentMethod.type.rawValue,
            type: .internal
        )
        errorEvent.code = AnalyticsConstants.ErrorCode.encryptionError.stringValue
        analyticsProvider?.add(error: errorEvent)
    }

}
