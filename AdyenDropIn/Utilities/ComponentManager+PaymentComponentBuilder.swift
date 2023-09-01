//
// Copyright (c) 2023 Adyen N.V.
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
#if canImport(AdyenCashAppPay)
    import AdyenCashAppPay
#endif
import Foundation

extension ComponentManager: PaymentComponentBuilder {

    func build(paymentMethod: StoredCardPaymentMethod) -> PaymentComponent? {
        createCardComponent(with: paymentMethod)
    }

    func build(paymentMethod: StoredPaymentMethod) -> PaymentComponent? {
        StoredPaymentMethodComponent(paymentMethod: paymentMethod,
                                     context: context,
                                     configuration: .init(localizationParameters: configuration.localizationParameters))
    }

    func build(paymentMethod: StoredBCMCPaymentMethod) -> PaymentComponent? {
        StoredPaymentMethodComponent(paymentMethod: paymentMethod,
                                     context: context,
                                     configuration: .init(localizationParameters: configuration.localizationParameters))
    }
    
    func build(paymentMethod: StoredACHDirectDebitPaymentMethod) -> PaymentComponent? {
        StoredPaymentMethodComponent(paymentMethod: paymentMethod,
                                     context: context,
                                     configuration: .init(localizationParameters: configuration.localizationParameters))
    }
    
    func build(paymentMethod: StoredCashAppPayPaymentMethod) -> PaymentComponent? {
        StoredPaymentMethodComponent(paymentMethod: paymentMethod,
                                     context: context,
                                     configuration: .init(localizationParameters: configuration.localizationParameters))
    }

    func build(paymentMethod: CardPaymentMethod) -> PaymentComponent? {
        createCardComponent(with: paymentMethod)
    }

    func build(paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        createBancontactComponent(with: paymentMethod)
    }

    func build(paymentMethod: IssuerListPaymentMethod) -> PaymentComponent? {
        IssuerListComponent(paymentMethod: paymentMethod,
                            context: context,
                            configuration: .init(style: configuration.style.listComponent,
                                                 localizationParameters: configuration.localizationParameters))
    }

    func build(paymentMethod: SEPADirectDebitPaymentMethod) -> PaymentComponent? {
        createSEPAComponent(paymentMethod)
    }

    func build(paymentMethod: BACSDirectDebitPaymentMethod) -> PaymentComponent? {
        createBACSDirectDebit(paymentMethod)
    }

    func build(paymentMethod: ACHDirectDebitPaymentMethod) -> PaymentComponent? {
        createACHDirectDebitComponent(paymentMethod)
    }

    func build(paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        createPreApplePayComponent(with: paymentMethod)
    }

    func build(paymentMethod: WeChatPayPaymentMethod) -> PaymentComponent? {
        guard let classObject = loadTheConcreteWeChatPaySDKActionComponentClass() else { return nil }
        guard classObject.isDeviceSupported() else { return nil }
        return InstantPaymentComponent(paymentMethod: paymentMethod,
                                       context: context,
                                       order: order)
    }

    func build(paymentMethod: QiwiWalletPaymentMethod) -> PaymentComponent? {
        createQiwiWalletComponent(paymentMethod)
    }

    func build(paymentMethod: MBWayPaymentMethod) -> PaymentComponent? {
        createMBWayComponent(paymentMethod)
    }

    func build(paymentMethod: BLIKPaymentMethod) -> PaymentComponent? {
        createBLIKComponent(paymentMethod)
    }

    func build(paymentMethod: EContextPaymentMethod) -> PaymentComponent? {
        let config = BasicPersonalInfoFormComponent.Configuration(style: configuration.style.formComponent,
                                                                  shopperInformation: configuration.shopperInformation,
                                                                  localizationParameters: configuration.localizationParameters)
        return BasicPersonalInfoFormComponent(paymentMethod: paymentMethod,
                                              context: context,
                                              configuration: config)
    }

    func build(paymentMethod: DokuPaymentMethod) -> PaymentComponent? {
        let config = DokuComponent.Configuration(style: configuration.style.formComponent,
                                                 shopperInformation: configuration.shopperInformation,
                                                 localizationParameters: configuration.localizationParameters)
        return DokuComponent(paymentMethod: paymentMethod,
                             context: context,
                             configuration: config)
    }

    func build(paymentMethod: GiftCardPaymentMethod) -> PaymentComponent? {
        guard let amount = context.payment?.amount, partialPaymentEnabled else { return nil }
        return GiftCardComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 amount: amount,
                                 style: configuration.style.formComponent,
                                 showsSecurityCodeField: configuration.giftCard.showsSecurityCodeField)
    }
    
    func build(paymentMethod: MealVoucherPaymentMethod) -> PaymentComponent? {
        guard let amount = context.payment?.amount, partialPaymentEnabled else { return nil }
        return GiftCardComponent(paymentMethod: paymentMethod,
                                 context: context,
                                 amount: amount,
                                 style: configuration.style.formComponent,
                                 showsSecurityCodeField: configuration.giftCard.showsSecurityCodeField)
    }

    func build(paymentMethod: BoletoPaymentMethod) -> PaymentComponent? {
        createBoletoComponent(paymentMethod)
    }

    func build(paymentMethod: AffirmPaymentMethod) -> PaymentComponent? {
        let config = AffirmComponent.Configuration(style: configuration.style.formComponent,
                                                   shopperInformation: configuration.shopperInformation,
                                                   localizationParameters: configuration.localizationParameters)
        return AffirmComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: config)
    }

    func build(paymentMethod: PaymentMethod) -> PaymentComponent? {
        InstantPaymentComponent(paymentMethod: paymentMethod,
                                context: context,
                                order: order)
    }

    func build(paymentMethod: AtomePaymentMethod) -> PaymentComponent? {
        let config = AtomeComponent.Configuration(style: configuration.style.formComponent,
                                                  shopperInformation: configuration.shopperInformation,
                                                  localizationParameters: configuration.localizationParameters)
        return AtomeComponent(paymentMethod: paymentMethod,
                              context: context,
                              configuration: config)
    }

    func build(paymentMethod: OnlineBankingPaymentMethod) -> PaymentComponent? {
        OnlineBankingComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: .init(style: configuration.style.formComponent))
    }

    func build(paymentMethod: UPIPaymentMethod) -> PaymentComponent? {
        UPIComponent(paymentMethod: paymentMethod,
                     context: context,
                     configuration: .init(style: configuration.style.formComponent))
    }
    
    func build(paymentMethod: CashAppPayPaymentMethod) -> PaymentComponent? {
        #if canImport(PayKit)
            guard let cashAppPayDropInConfig = configuration.cashAppPay else {
                AdyenAssertion.assertionFailure(
                    message: "Cash App Pay configuration instance must not be nil in order to use CashAppPayComponent")
                return nil
            }
            if #available(iOS 13.0, *) {
                var cashAppPayConfiguration = CashAppPayConfiguration(redirectURL: cashAppPayDropInConfig.redirectURL,
                                                                      referenceId: cashAppPayDropInConfig.referenceId)
                cashAppPayConfiguration.showsStorePaymentMethodField = cashAppPayDropInConfig.showsStorePaymentMethodField
                cashAppPayConfiguration.localizationParameters = configuration.localizationParameters
                cashAppPayConfiguration.style = configuration.style.formComponent
        
                return CashAppPayComponent(paymentMethod: paymentMethod,
                                           context: context,
                                           configuration: cashAppPayConfiguration)
            } else {
                return nil
            }
        #else
            return nil
        #endif
    }

    private func createCardComponent(with paymentMethod: AnyCardPaymentMethod) -> PaymentComponent? {
        var cardConfiguration = configuration.card.cardComponentConfiguration
        cardConfiguration.style = configuration.style.formComponent
        cardConfiguration.localizationParameters = configuration.localizationParameters
        cardConfiguration.shopperInformation = configuration.shopperInformation
        return CardComponent(paymentMethod: paymentMethod,
                             context: context,
                             configuration: cardConfiguration)
    }

    private func createBancontactComponent(with paymentMethod: BCMCPaymentMethod) -> PaymentComponent? {
        let cardConfiguration = configuration.card
        let configuration = CardComponent.Configuration(style: configuration.style.formComponent,
                                                        shopperInformation: configuration.shopperInformation,
                                                        localizationParameters: configuration.localizationParameters,
                                                        showsHolderNameField: cardConfiguration.showsHolderNameField,
                                                        showsStorePaymentMethodField: cardConfiguration.showsStorePaymentMethodField,
                                                        showsSecurityCodeField: cardConfiguration.showsSecurityCodeField,
                                                        storedCardConfiguration: cardConfiguration.stored)

        return BCMCComponent(paymentMethod: paymentMethod,
                             context: context,
                             configuration: configuration)
    }

    private func createPreApplePayComponent(with paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        guard let applePay = configuration.applePay else {
            adyenPrint("Failed to instantiate ApplePayComponent because ApplePayConfiguration is missing")
            return nil
        }

        let preApplePayConfig = PreApplePayComponent.Configuration(style: configuration.style.applePay,
                                                                   localizationParameters: configuration.localizationParameters)

        if let amount = order?.remainingAmount {
            let configuration = applePay.replacing(amount: amount)
            if let component = try? PreApplePayComponent(paymentMethod: paymentMethod,
                                                         context: context,
                                                         configuration: preApplePayConfig,
                                                         applePayConfiguration: configuration) {
                return component
            }
        }

        do {
            return try PreApplePayComponent(paymentMethod: paymentMethod,
                                            context: context,
                                            configuration: preApplePayConfig,
                                            applePayConfiguration: applePay)
        } catch {
            adyenPrint("Failed to instantiate ApplePayComponent because of error: \(error.localizedDescription)")
            return nil
        }
    }

    private func createSEPAComponent(_ paymentMethod: SEPADirectDebitPaymentMethod) -> SEPADirectDebitComponent {
        let config = SEPADirectDebitComponent.Configuration(style: configuration.style.formComponent,
                                                            localizationParameters: configuration.localizationParameters)
        return SEPADirectDebitComponent(paymentMethod: paymentMethod,
                                        context: context,
                                        configuration: config)
    }

    private func createBACSDirectDebit(_ paymentMethod: BACSDirectDebitPaymentMethod) -> BACSDirectDebitComponent {
        let bacsConfiguration = BACSDirectDebitComponent.Configuration(style: configuration.style.formComponent,
                                                                       localizationParameters: configuration.localizationParameters)
        let bacsDirectDebitComponent = BACSDirectDebitComponent(paymentMethod: paymentMethod,
                                                                context: context,
                                                                configuration: bacsConfiguration)
        bacsDirectDebitComponent.presentationDelegate = presentationDelegate
        return bacsDirectDebitComponent
    }

    private func createACHDirectDebitComponent(_ paymentMethod: ACHDirectDebitPaymentMethod) -> ACHDirectDebitComponent {
        let config = ACHDirectDebitComponent.Configuration(style: configuration.style.formComponent,
                                                           shopperInformation: configuration.shopperInformation,
                                                           localizationParameters: configuration.localizationParameters,
                                                           showsStorePaymentMethodField: configuration.ach.showsStorePaymentMethodField,
                                                           showsBillingAddress: configuration.ach.showsBillingAddress,
                                                           billingAddressCountryCodes: configuration.ach.billingAddressCountryCodes)
        return ACHDirectDebitComponent(paymentMethod: paymentMethod,
                                       context: context,
                                       configuration: config)
    }

    private func createQiwiWalletComponent(_ paymentMethod: QiwiWalletPaymentMethod) -> QiwiWalletComponent {
        let config = QiwiWalletComponent.Configuration(style: configuration.style.formComponent,
                                                       shopperInformation: configuration.shopperInformation,
                                                       localizationParameters: configuration.localizationParameters)
        return QiwiWalletComponent(paymentMethod: paymentMethod,
                                   context: context,
                                   configuration: config)
    }

    private func createMBWayComponent(_ paymentMethod: MBWayPaymentMethod) -> MBWayComponent? {
        let config = MBWayComponent.Configuration(style: configuration.style.formComponent,
                                                  shopperInformation: configuration.shopperInformation,
                                                  localizationParameters: configuration.localizationParameters)
        return MBWayComponent(paymentMethod: paymentMethod,
                              context: context,
                              configuration: config)
    }

    private func createBLIKComponent(_ paymentMethod: BLIKPaymentMethod) -> BLIKComponent? {
        let config = BLIKComponent.Configuration(style: configuration.style.formComponent,
                                                 localizationParameters: configuration.localizationParameters)
        return BLIKComponent(paymentMethod: paymentMethod,
                             context: context,
                             configuration: config)
    }

    private func createBoletoComponent(_ paymentMethod: BoletoPaymentMethod) -> BoletoComponent {
        let config = BoletoComponent.Configuration(style: configuration.style.formComponent,
                                                   localizationParameters: configuration.localizationParameters,
                                                   shopperInformation: configuration.shopperInformation,
                                                   showEmailAddress: configuration.boleto.showEmailAddress)
        return BoletoComponent(paymentMethod: paymentMethod,
                               context: context,
                               configuration: config)
    }

}
