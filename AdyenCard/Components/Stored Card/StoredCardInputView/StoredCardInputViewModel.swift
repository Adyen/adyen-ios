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
import Combine
import Foundation

// sourcery: AutoMockable
internal protocol StoredCardInputViewModelProtocol: AnyObject {
    var cardImageItem: CardImageItem { get }
    var titleText: String { get }
    var subtitleText: NSAttributedString { get }

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

    private enum Constants {
        static let cardImageSize = CGSize(width: 80, height: 52)
    }

    private let localizationParameters: LocalizationParameters?
    private var storedCardPaymentMethod: StoredCardPaymentMethod
    private let apiContext: APIContext
    private let analyticsProvider: AnyAnalyticsProvider?
    private let amount: Amount?
    private let publicKey: String
    private let cardBrand: CardType

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
        apiContext: APIContext,
        publicKey: String,
        amount: Amount?,
        analyticsProvider: AnyAnalyticsProvider?,
        localizationParameters: LocalizationParameters?,
        cardBrand: CardType
    ) {
        self.theme = theme
        self.storedCardPaymentMethod = storedCardPaymentMethod
        self.amount = amount
        self.apiContext = apiContext
        self.publicKey = publicKey
        self.localizationParameters = localizationParameters
        self.analyticsProvider = analyticsProvider
        self.cardBrand = cardBrand
    }

    internal lazy var cardImageItem: CardImageItem = {
        let displayInformation = storedCardPaymentMethod.displayInformation(using: localizationParameters)
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
        // TODO: Robert: StoredView: The keys will change when we get the localization. So the keys will need to be updated.
        localizedString(.cardSecurityCodeTitle, localizationParameters)
    }

    // TODO: Robert: StoredView: This & the pay button title needs to change according to the amount.
    /// We construct something like - Enter the security code for BOLD[Visa •••• 4556]
    internal var subtitleText: NSAttributedString {
        let displayInformation = storedCardPaymentMethod.displayInformation(using: localizationParameters)
        let paymentMethodTitle = storedCardPaymentMethod.name + " " + displayInformation.title
        let localizedString = localizedString(.cardSecurityCodeDescription, localizationParameters, paymentMethodTitle)

        let attributed = NSMutableAttributedString(string: localizedString)

        let range = (localizedString as NSString).range(of: paymentMethodTitle)
        attributed.addAttribute(.font, value: theme.elements.labels.bodyEmphasized.font, range: range)
        attributed.addAttribute(.foregroundColor, value: theme.elements.labels.bodyEmphasized.color, range: range)

        return attributed
    }

    internal var submitButtonTitle: String {
        localizedSubmitButtonTitle(
            with: amount,
            style: .immediate,
            localizationParameters
        )
    }

    internal func viewDidLoad() {
        sendDidLoadEvent()
        securityCodeItem.selectedCard = cardBrand
    }

    @MainActor internal func viewDidDisappear() {
        resetSecurityCodeField()
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
