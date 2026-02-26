//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

internal protocol StoredCardInputViewModelProtocol: AnyObject {
    var cardImageItem: CardImageItem { get }
    var titleText: String { get }
    var subtitleText: String { get }

    var securityCodeItem: FormCardSecurityCodeItem { get }

    var inputFieldTitle: String { get }
    var inputFieldSubTitle: String { get }

    var submitButtonTitle: String { get }
    func submitPayment()

    func returnToPreviousScreen()

    var theme: AdyenTheme { get }
    var setPayButtonEnabled: ((Bool) -> Void)? { get set }
}

internal final class StoredCardInputViewModel: StoredCardInputViewModelProtocol {
    private enum Constants {
        static let cardImageSize = CGSize(width: 80, height: 52)
    }

    private let component: PaymentComponent
    internal let theme: AdyenTheme
    private let localizationParameters: LocalizationParameters?

    internal var setPayButtonEnabled: ((Bool) -> Void)?

    init(
        theme: AdyenTheme,
        component: PaymentComponent,
        localizationParameters: LocalizationParameters?
    ) {
        self.theme = theme
        self.component = component
        self.localizationParameters = localizationParameters

        securityCodeItem.publisher.addEventHandler { [weak self] value in
            guard let self else { return }
            setPayButtonEnabled?(securityCodeItem.isValid())
        }
    }

    internal lazy var cardImageItem: AdyenUI.CardImageItem = {
        let paymentMethod = component.paymentMethod
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        // TODO: Robert: This will change as we will not rely on DisplayInformation for V6.
        let imageURL = LogoURLProvider.logoURL(
            withName: displayInformation.logoName,
            environment: component.context.apiContext.environment,
            size: .large
        )
        return CardImageItem(
            imageURL: imageURL,
            sizeMode: .fixed(Constants.cardImageSize),
            theme: theme
        )

        CardImageItem(imageURL: nil, sizeMode: .fixed(CGSizeZero), theme: .init())
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

    internal func submitPayment() {
        let securityCode: String = securityCodeItem.value
        print("BOB: securityCode: \(securityCode)")
    }

    internal func returnToPreviousScreen() {}
}
