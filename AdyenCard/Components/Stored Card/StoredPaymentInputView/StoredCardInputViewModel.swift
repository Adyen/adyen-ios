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
    var subtitleText: NSAttributedString { get }

    var securityCodeItem: FormCardSecurityCodeItem { get }

    var submitButtonTitle: String { get }
    func submitPayment() async

    var showAllPaymentMethodsButtonTitle: String { get }
    func showAllPaymentMethods()

    func returnToPreviousScreen()

    var theme: AdyenTheme { get }

    var setPayButtonEnabled: ((Bool) -> Void)? { get set }
}

internal final class StoredCardInputViewModel: StoredCardInputViewModelProtocol, AdyenObserver {
    private enum Constants {
        static let cardImageSizeCardArtNotAvailable = CGSize(width: 80, height: 52)
    }

    internal let theme: AdyenTheme
    private let localizationParameters: LocalizationParameters?
    private let paymentMethod: StoredCardPaymentMethod
    private let apiContext: APIContext
    private let analyticsProvider: AnyAnalyticsProvider?
    private let amount: Amount?
    internal var setPayButtonEnabled: ((Bool) -> Void)?

    /// This informs the status of the payment after submitting the security code.
    internal var cardDetailsCompletionHandler: Completion<Result<CardDetails, Error>>?
    internal var publicKeyProvider: AnyPublicKeyProvider

    internal init(
        theme: AdyenTheme,
        paymentMethod: StoredCardPaymentMethod,
        apiContext: APIContext,
        amount: Amount?,
        analyticsProvider: AnyAnalyticsProvider?,
        localizationParameters: LocalizationParameters?
    ) {
        self.theme = theme
        self.paymentMethod = paymentMethod
        self.amount = amount
        self.apiContext = apiContext
        self.localizationParameters = localizationParameters
        self.analyticsProvider = analyticsProvider
        self.publicKeyProvider = PublicKeyProvider(apiContext: apiContext)

        observe(securityCodeItem.publisher) { [weak self] event in
            guard let self else { return }
            setPayButtonEnabled?(securityCodeItem.isValid())
        }
    }

    internal lazy var cardImageItem: AdyenUI.CardImageItem = {
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let imageURL = LogoURLProvider.logoURL(
            withName: displayInformation.logoName,
            environment: apiContext.environment,
            size: .large
        )
        return CardImageItem(
            imageURL: imageURL,
            sizeMode: .fixed(Constants.cardImageSizeCardArtNotAvailable),
            theme: theme
        )
    }()

    internal lazy var securityCodeItem: FormCardSecurityCodeItem = {
        let item = FormCardSecurityCodeItem()
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItem")
        return item
    }()

    internal var titleText: String {
        localizedString(.cardComponentInputTitle, localizationParameters)
    }

    /// We construct something like - Enter the security code for BOLD[Visa •••• 4556] to complete the payment of BOLD[$140.98]
    internal var subtitleText: NSAttributedString {
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let paymentMethodTitle = paymentMethod.name + displayInformation.title
        let localizedString = localizedString(.cardComponentInputDescription, localizationParameters, paymentMethodTitle, formattedAmount)

        let attributed = NSMutableAttributedString(string: localizedString)

        let range = (localizedString as NSString).range(of: paymentMethodTitle)
        attributed.addAttribute(.font, value: theme.elements.labels.bodyEmphasized.font, range: range)
        attributed.addAttribute(.foregroundColor, value: theme.elements.labels.bodyEmphasized.color, range: range)

        let amountRange = (localizedString as NSString).range(of: formattedAmount)
        attributed.addAttribute(.font, value: theme.elements.labels.bodyEmphasized.font, range: amountRange)
        attributed.addAttribute(.foregroundColor, value: theme.elements.labels.bodyEmphasized.color, range: amountRange)

        return attributed
    }

    private var formattedAmount: String {
        guard let amount,
              let formatted = AmountFormatter.formatted(amount: amount.value, currencyCode: amount.currencyCode) else {
            return ""
        }
        return formatted
    }

    internal var submitButtonTitle: String {
        localizedString(.submitButtonFormatted, localizationParameters, formattedAmount)
    }

    internal func returnToPreviousScreen() {
        // TODO: Robert: StoredView: Inform the router to pop me out.
    }

    // MARK: - Other payment options

    internal var showAllPaymentMethodsButtonTitle: String {
        localizedString(.preselectedPaymentMethodOtherOptions, localizationParameters)
    }

    internal func showAllPaymentMethods() {
        // TODO: Robert: StoredView: Inform the router to navigation to the payment list.
    }

    // MARK: - Submit payment

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

    internal func resetSecurityCodeField() {
        securityCodeItem.value = ""
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
