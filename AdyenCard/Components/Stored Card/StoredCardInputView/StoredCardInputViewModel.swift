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

internal enum StoredCardInputViewInstruction: Equatable {
    case setLoading(Bool)
    case showSecurityCodeValidation
}

// sourcery: AutoMockable
internal protocol StoredCardInputViewModelProtocol: AnyObject {
    var cardImageItem: CardImageItem { get }
    var titleText: String { get }
    var subtitleText: NSAttributedString { get }

    var securityCodeItem: FormCardSecurityCodeItem { get }

    var submitButtonTitle: String { get }
    @MainActor func submit() async

    var showAllPaymentMethodsButtonTitle: String { get }
    func showAllPaymentMethods()

    func dismiss()

    var theme: AdyenTheme { get }

    var onViewInstruction: Completion<StoredCardInputViewInstruction>? { get set }

    func viewDidLoad()
}

internal final class StoredCardInputViewModel: StoredCardInputViewModelProtocol, AdyenObserver {

    private enum Constants {
        static let cardImageSizeCardArtNotAvailable = CGSize(width: 80, height: 52)
    }

    private let localizationParameters: LocalizationParameters?
    private var storedCardPaymentMethod: StoredCardPaymentMethod
    private let apiContext: APIContext
    private let analyticsProvider: AnyAnalyticsProvider?
    private let amount: Amount?
    private let publicKey: String

    internal let theme: AdyenTheme
    internal var onViewInstruction: Completion<StoredCardInputViewInstruction>?

    /// This informs the status of the payment after submitting the security code.
    internal var cardDetailsCompletionHandler: Completion<Result<CardDetails, Error>>?
    internal var otherPaymentOptionsHandler: VoidCompletion?
    internal var closeHandler: VoidCompletion?

    internal init(
        theme: AdyenTheme,
        storedCardPaymentMethod: StoredCardPaymentMethod,
        apiContext: APIContext,
        publicKey: String,
        amount: Amount?,
        analyticsProvider: AnyAnalyticsProvider?,
        localizationParameters: LocalizationParameters?
    ) {
        self.theme = theme
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.amount = amount
        self.apiContext = apiContext
        self.publicKey = publicKey
        self.localizationParameters = localizationParameters
        self.analyticsProvider = analyticsProvider
    }

    internal lazy var cardImageItem: AdyenUI.CardImageItem = {
        let displayInformation = storedCardPaymentMethod.displayInformation(using: localizationParameters)
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
        let displayInformation = storedCardPaymentMethod.displayInformation(using: localizationParameters)
        let paymentMethodTitle = storedCardPaymentMethod.name + displayInformation.title
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
              let formatted = AmountFormatter.formatted(
                  amount: amount.value,
                  currencyCode: amount.currencyCode
              ) else {
            return ""
        }
        return formatted
    }

    internal var submitButtonTitle: String {
        localizedString(.submitButtonFormatted, localizationParameters, formattedAmount)
    }

    internal func viewDidLoad() {
        sendDidLoadEvent()
    }

    @MainActor internal func dismiss() {
        resetSecurityCodeField()
        closeHandler?()
    }

    // MARK: - Other payment options

    internal var showAllPaymentMethodsButtonTitle: String {
        localizedString(.preselectedPaymentMethodOtherOptions, localizationParameters)
    }

    @MainActor internal func showAllPaymentMethods() {
        resetSecurityCodeField()
        otherPaymentOptionsHandler?()
    }

    // MARK: - Submit payment

    @MainActor internal func submit() async {
        guard securityCodeItem.isValid() else {
            onViewInstruction?(.showSecurityCodeValidation)
            return
        }

        onViewInstruction?(.setLoading(true))

        let securityCode: String = securityCodeItem.value
        resetSecurityCodeField()

        await submitPayment(securityCode: securityCode)
        onViewInstruction?(.setLoading(false))
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
