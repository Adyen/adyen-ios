//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenCard)
    @_spi(AdyenInternal) import AdyenCard
#endif
#if canImport(AdyenComponents)
    @_spi(AdyenInternal) import AdyenComponents
#endif
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
#if canImport(AdyenUI)
    import AdyenUI
#endif
#if canImport(AdyenCashAppPay)
    import AdyenCashAppPay
#endif
#if canImport(AdyenTwint)
    import AdyenTwint
#endif
import Foundation

// TODO: Remove this legacy builder in PR 3 after AdyenCheckout injects CheckoutComponentBuilder.
// Default component styles below are a temporary compatibility bridge, not Drop-in configuration defaults.
extension ComponentManager: PaymentComponentBuilder {

    internal func build(paymentMethod: StoredCardPaymentMethod) -> PaymentComponent? {
        let cardComponent = createCardComponent(with: paymentMethod)
        return cardComponent.storedCardComponent
    }

    internal func build(paymentMethod: StoredPaymentMethod) -> PaymentComponent? {
        let storedPaymentMethodComponent = StoredPaymentMethodComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        storedPaymentMethodComponent.localizationParameters = configuration.resolvedLocalizationParameters
        return storedPaymentMethodComponent
    }

    internal func build(paymentMethod: StoredBCMCPaymentMethod) -> PaymentComponent? {
        let storedPaymentMethodComponent = StoredPaymentMethodComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        storedPaymentMethodComponent.localizationParameters = configuration.resolvedLocalizationParameters
        return storedPaymentMethodComponent
    }

    internal func build(paymentMethod: StoredACHDirectDebitPaymentMethod) -> PaymentComponent? {
        let storedPaymentMethodComponent = StoredPaymentMethodComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        storedPaymentMethodComponent.localizationParameters = configuration.resolvedLocalizationParameters
        return storedPaymentMethodComponent
    }

    internal func build(paymentMethod: StoredCashAppPayPaymentMethod) -> PaymentComponent? {
        let storedPaymentMethodComponent = StoredPaymentMethodComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        storedPaymentMethodComponent.localizationParameters = configuration.resolvedLocalizationParameters
        return storedPaymentMethodComponent
    }

    internal func build(paymentMethod: StoredTwintPaymentMethod) -> PaymentComponent? {
        let storedPaymentMethodComponent = StoredPaymentMethodComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        storedPaymentMethodComponent.localizationParameters = configuration.resolvedLocalizationParameters
        return storedPaymentMethodComponent
    }

    internal func build(paymentMethod: CardPaymentMethod) -> PaymentComponent? {
        createCardComponent(with: paymentMethod)
    }

    internal func build(paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        createBancontactComponent(with: paymentMethod)
    }

    internal func build(paymentMethod: IssuerListPaymentMethod) -> PaymentComponent? {
        IssuerListComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: .init(
                style: ListComponentStyle(),
                localizationParameters: configuration.resolvedLocalizationParameters
            )
        )
    }

    internal func build(paymentMethod: SEPADirectDebitPaymentMethod) -> PaymentComponent? {
        createSEPAComponent(paymentMethod)
    }

    internal func build(paymentMethod: BACSDirectDebitPaymentMethod) -> PaymentComponent? {
        createBACSDirectDebit(paymentMethod)
    }

    internal func build(paymentMethod: ACHDirectDebitPaymentMethod) -> PaymentComponent? {
        createACHDirectDebitComponent(paymentMethod)
    }

    internal func build(paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        createApplePayComponent(with: paymentMethod)
    }

    internal func build(paymentMethod: WeChatPayPaymentMethod) -> PaymentComponent? {
        guard let classObject = loadTheConcreteWeChatPaySDKActionComponentClass() else { return nil }
        guard classObject.isDeviceSupported() else { return nil }
        return GenericPaymentComponent(
            paymentMethod: paymentMethod,
            context: context,
            order: order
        )
    }

    internal func build(paymentMethod: QiwiWalletPaymentMethod) -> PaymentComponent? {
        createQiwiWalletComponent(paymentMethod)
    }

    internal func build(paymentMethod: MBWayPaymentMethod) -> PaymentComponent? {
        createMBWayComponent(paymentMethod)
    }

    internal func build(paymentMethod: BLIKPaymentMethod) -> PaymentComponent? {
        createBLIKComponent(paymentMethod)
    }

    internal func build(paymentMethod: EContextPaymentMethod) -> PaymentComponent? {
        let config = BasicPersonalInfoFormComponent.Configuration(
            style: FormComponentStyle(),
            shopperInformation: nil,
            localizationParameters: configuration.resolvedLocalizationParameters
        )
        return BasicPersonalInfoFormComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }

    internal func build(paymentMethod: DokuPaymentMethod) -> PaymentComponent? {
        let config = DokuComponent.Configuration(
            style: FormComponentStyle(),
            shopperInformation: nil,
            localizationParameters: configuration.resolvedLocalizationParameters
        )
        return DokuComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }

    internal func build(paymentMethod: GiftCardPaymentMethod) -> PaymentComponent? {
        guard let amount = context.amount, partialPaymentEnabled else { return nil }
        return GiftCardComponent(
            paymentMethod: paymentMethod,
            context: context,
            amount: amount,
            style: FormComponentStyle(),
            showsSecurityCodeField: true
        )
    }

    internal func build(paymentMethod: MealVoucherPaymentMethod) -> PaymentComponent? {
        guard let amount = context.amount, partialPaymentEnabled else { return nil }
        return GiftCardComponent(
            paymentMethod: paymentMethod,
            context: context,
            amount: amount,
            style: FormComponentStyle(),
            showsSecurityCodeField: true
        )
    }

    internal func build(paymentMethod: BoletoPaymentMethod) -> PaymentComponent? {
        createBoletoComponent(paymentMethod)
    }

    internal func build(paymentMethod: AffirmPaymentMethod) -> PaymentComponent? {
        let config = AffirmComponent.Configuration(
            style: FormComponentStyle(),
            shopperInformation: nil,
            localizationParameters: configuration.resolvedLocalizationParameters
        )
        return AffirmComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }

    internal func build(paymentMethod: PaymentMethod) -> PaymentComponent? {
        GenericPaymentComponent(
            paymentMethod: paymentMethod,
            context: context,
            order: order
        )
    }

    internal func build(paymentMethod: AtomePaymentMethod) -> PaymentComponent? {
        let config = AtomeComponent.Configuration(
            style: FormComponentStyle(),
            shopperInformation: nil,
            localizationParameters: configuration.resolvedLocalizationParameters
        )
        return AtomeComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }

    internal func build(paymentMethod: OnlineBankingPaymentMethod) -> PaymentComponent? {
        OnlineBankingComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: .init(style: FormComponentStyle())
        )
    }

    internal func build(paymentMethod: UPIPaymentMethod) -> PaymentComponent? {
        UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: .init(style: FormComponentStyle())
        )
    }

    internal func build(paymentMethod: TwintPaymentMethod) -> PaymentComponent? {
        #if canImport(TwintSDK)
            let twintConfiguration = TwintComponent.Configuration(
                style: FormComponentStyle(),
                localizationParameters: configuration.resolvedLocalizationParameters
            )
            return TwintComponent(
                paymentMethod: paymentMethod,
                context: context,
                configuration: twintConfiguration
            )
        #else
            return nil
        #endif
    }

    internal func build(paymentMethod: CashAppPayPaymentMethod) -> PaymentComponent? {
        #if canImport(PayKit)
            return nil
        #else
            return nil
        #endif
    }
    
    internal func build(paymentMethod: PayByBankUSPaymentMethod) -> PaymentComponent? {
        let configuration: PayByBankUSComponent.Configuration = .init()
        return PayByBankUSComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
    }
    
    internal func build(paymentMethod: PayToPaymentMethod) -> PaymentComponent? {
        PayToComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: .init(style: FormComponentStyle())
        )
    }
    
    internal func build(paymentMethod: StoredPayToPaymentMethod) -> (any PaymentComponent)? {
        StoredPaymentMethodComponent(
            paymentMethod: paymentMethod,
            context: context
            // configuration: .init(localizationParameters: configuration.resolvedLocalizationParameters)
        )
    }
}

// MARK: - Privates

private extension ComponentManager {
    
    func createCardComponent(with paymentMethod: AnyCardPaymentMethod) -> CardComponent {
        var cardConfiguration = CardConfiguration()
        cardConfiguration.style = FormComponentStyle()
        cardConfiguration.localizationProvider = configuration.localizationProvider
        cardConfiguration.theme = configuration.theme
        return CardComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: cardConfiguration
        )
    }

    func createBancontactComponent(with paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        // TODO: To be replaced with a factory call
        var cardConfiguration = CardConfiguration()
        cardConfiguration.style = FormComponentStyle()
        cardConfiguration.localizationProvider = configuration.localizationProvider
        cardConfiguration.theme = configuration.theme
        return BCMCComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: cardConfiguration
        )
    }

    func createApplePayComponent(with paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        nil
    }

    func createSEPAComponent(_ paymentMethod: SEPADirectDebitPaymentMethod) -> SEPADirectDebitComponent {
        let config = SEPADirectDebitComponent.Configuration(
            style: FormComponentStyle(),
            localizationParameters: configuration.resolvedLocalizationParameters
        )
        return SEPADirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }

    func createBACSDirectDebit(_ paymentMethod: BACSDirectDebitPaymentMethod) -> BACSDirectDebitComponent {
        let bacsConfiguration = BACSDirectDebitComponent.Configuration(
            style: FormComponentStyle(),
            localizationParameters: configuration.resolvedLocalizationParameters
        )
        let bacsDirectDebitComponent = BACSDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: bacsConfiguration
        )
        bacsDirectDebitComponent.presentationDelegate = presentationDelegate
        return bacsDirectDebitComponent
    }

    func createACHDirectDebitComponent(_ paymentMethod: ACHDirectDebitPaymentMethod) -> ACHDirectDebitComponent {
        var config = ACHDirectDebitConfiguration()
        config.localizationParameters = configuration.resolvedLocalizationParameters
        config.theme = configuration.theme
        return ACHDirectDebitComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }

    func createQiwiWalletComponent(_ paymentMethod: QiwiWalletPaymentMethod) -> QiwiWalletComponent {
        let config = QiwiWalletComponent.Configuration(
            style: FormComponentStyle(),
            shopperInformation: nil,
            localizationParameters: configuration.resolvedLocalizationParameters
        )
        return QiwiWalletComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }

    func createMBWayComponent(_ paymentMethod: MBWayPaymentMethod) -> MBWayComponent? {
        let config = MBWayComponent.Configuration(
            style: FormComponentStyle(),
            shopperInformation: nil,
            localizationParameters: configuration.resolvedLocalizationParameters
        )
        return MBWayComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }

    func createBLIKComponent(_ paymentMethod: BLIKPaymentMethod) -> BLIKComponent? {
        let config = BLIKComponentConfiguration(
            localizationParameters: configuration.resolvedLocalizationParameters,
            theme: configuration.theme
        )
        return BLIKComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }

    func createBoletoComponent(_ paymentMethod: BoletoPaymentMethod) -> BoletoComponent {
        let config = BoletoComponent.Configuration(
            style: FormComponentStyle(),
            localizationParameters: configuration.resolvedLocalizationParameters,
            shopperInformation: nil,
            showEmailAddress: true
        )
        return BoletoComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: config
        )
    }
}
