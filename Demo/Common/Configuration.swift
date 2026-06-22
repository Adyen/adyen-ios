//
// Copyright (c) 2017 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import AdyenDropIn
import Foundation
import PassKit
#if canImport(AdyenUI)
    import AdyenUI
#endif

internal enum ConfigurationConstants {
    // swiftlint:disable explicit_acl
    // swiftlint:disable line_length
    
    /// Please use your own web server between your app and adyen checkout API.
    static let demoServerEnvironment = DemoCheckoutAPIEnvironment.test
    
    static let componentsEnvironment = Environment.test
    
    static let appName = "Adyen Demo"
    
    static let reference = "Test Order Reference - iOS UIHost"
    
    static var returnUrl: URL {
        .init(string: "ui-host://payments")!
    }
    
    static let shopperReference = "iOS Checkout Shopper"

    static let shopperEmail = "checkoutShopperiOS@example.org"
    static let recurringProcessingModel = "CardOnFile"

    static var apiContext: APIContext {
        if let apiContext = try? APIContext(environment: componentsEnvironment, clientKey: clientKey) {
            return apiContext
        }
        // swiftlint:disable:next force_try
        return try! APIContext(environment: componentsEnvironment, clientKey: "local_DUMMYKEYFORTESTING")
    }

    static let clientKey = secretValue(for: .clientKey)
    
    static let serverUrl = secretValue(for: .serverUrl)
    
    static let merchantAccount = secretValue(for: .merchantAccount)
    
    static let adyenServerKey = secretValue(for: .adyenServerKey)

    static let appleTeamIdentifier = secretValue(for: .appleTeamIdentifier)

    static let applePayMerchantIdentifier = secretValue(for: .applePayMerchantIdentifier)

    static let lineItems = [[
        "description": "Socks",
        "quantity": "2",
        "amountIncludingTax": "300",
        "amountExcludingTax": "248",
        "taxAmount": "52",
        "id": "Item #2"
    ]]
    
    /// sample mandate object (e.g., for PayTo)
    static let mandate = [
        "amount": "\(current.amount.value)",
        "amountRule": "max",
        "endsAt": "2027-10-01",
        "frequency": "adhoc",
        "remarks": "Remark on mandate"
    ]
    
    static var delegatedAuthenticationConfigurations: AuthenticationConfiguration.DelegatedAuthentication {
        .init(relyingPartyIdentifier: "test-authentication-adyen.netlify.app")
    }

    static var shippingMethods: [PKShippingMethod] = {
        var shippingByCar = PKShippingMethod(label: "By car", amount: NSDecimalNumber(5.0))
        shippingByCar.identifier = "car"
        shippingByCar.detail = "Tomorrow"

        var shippingByPlane = PKShippingMethod(label: "By Plane", amount: NSDecimalNumber(50.0))
        shippingByPlane.identifier = "plane"
        shippingByPlane.detail = "Today"
        
        return [shippingByCar, shippingByPlane]
    }()
    
    static var current = DemoAppSettings.loadConfiguration() {
        didSet { DemoAppSettings.saveConfiguration(current) }
    }

    // swiftlint:enable explicit_acl
    // swiftlint:enable line_length
}

internal struct CardSettings: Codable {
    internal var showCardholderName = false
    internal var showStorePaymentMethod = true
    internal var showSecurityCodeForStoredCard = true
    internal var showSecurityCode = true
    internal var addressMode: AddressFormType = .none
    internal var socialSecurityNumberVisibility: CardConfiguration.FieldVisibility = .auto
    internal var koreanAuthenticationVisibility: CardConfiguration.FieldVisibility = .auto
    internal var enableInstallments = false
    internal var showsInstallmentAmount = false
    
    internal enum AddressFormType: String, Codable, CaseIterable {
        case lookup
        case lookupMapKit
        case full
        case postalCode
        case none
    }
}

internal struct DropInSettings: Codable {
    internal var allowDisablingStoredPaymentMethods: Bool = false
    internal var allowsSkippingPaymentList: Bool = false
    internal var allowPreselectedPaymentView: Bool = true
}

internal struct ThreeDSConfigurationSettings: Codable {
    internal var allowForceCardRedirectAction: Bool
}

internal struct ApplePaySettings: Codable {
    internal var merchantIdentifier: String
    internal var allowOnboarding: Bool = false
    internal var didAuthorizeSuccessful: Bool = true
    internal var onBeforeSubmitMode: OnBeforeSubmitMode = .updateData

    internal enum OnBeforeSubmitMode: String, Codable, CaseIterable {
        case updateData
        case abort
        case patchSession
    }
}

internal struct AnalyticsSettings: Codable {
    internal var isEnabled: Bool = true
}

internal struct ThemeSettings: Codable {
    internal var selectedTheme: String = ExampleAppTheme.defaultOption.rawValue
    
    internal var theme: ExampleAppTheme {
        ExampleAppTheme(rawValue: selectedTheme) ?? .defaultTheme
    }
}

internal struct DemoAppSettings: Codable {
    private static let defaultsKey = "ConfigurationKey"
    
    internal var countryCode: String
    internal let value: Int
    internal var currencyCode: String
    internal let merchantAccount: String
    internal let cardSettings: CardSettings
    internal let dropInSettings: DropInSettings
    internal let threeDSConfigurationSettings: ThreeDSConfigurationSettings
    internal let applePaySettings: ApplePaySettings
    internal let analyticsSettings: AnalyticsSettings
    internal let themeSettings: ThemeSettings

    internal var amount: Amount {
        Amount(value: value, currencyCode: currencyCode, localeIdentifier: nil)
    }

    private var installmentConfiguration: InstallmentConfiguration? {
        guard cardSettings.enableInstallments else {
            return nil
        }
        let defaultInstallmentOptions = InstallmentOptions(monthValues: [2, 3, 4], includesRevolving: true)
        let visaInstallmentOptions = InstallmentOptions(monthValues: [3, 4, 6], includesRevolving: false)
        return InstallmentConfiguration(
            cardBasedOptions: [.visa: visaInstallmentOptions],
            defaultOptions: defaultInstallmentOptions,
            showInstallmentAmount: cardSettings.showsInstallmentAmount
        )
    }
    
    internal static let defaultConfiguration = DemoAppSettings(
        countryCode: "NL",
        value: 17408,
        currencyCode: "EUR",
        merchantAccount: ConfigurationConstants.merchantAccount,
        cardSettings: defaultCardSettings,
        dropInSettings: defaultDropInSettings,
        threeDSConfigurationSettings: threeDSConfigurationSettings,
        applePaySettings: defaultApplePaySettings,
        analyticsSettings: defaultAnalyticsSettings,
        themeSettings: defaultThemeSettings
    )

    internal static let defaultCardSettings = CardSettings(
        showCardholderName: false,
        showStorePaymentMethod: true,
        showSecurityCodeForStoredCard: true,
        showSecurityCode: true,
        addressMode: .none,
        socialSecurityNumberVisibility: .auto,
        koreanAuthenticationVisibility: .auto,
        enableInstallments: false,
        showsInstallmentAmount: false
    )

    internal static let defaultDropInSettings = DropInSettings(
        allowDisablingStoredPaymentMethods: false,
        allowsSkippingPaymentList: false,
        allowPreselectedPaymentView: true
    )
    
    internal static let threeDSConfigurationSettings = ThreeDSConfigurationSettings(
        allowForceCardRedirectAction: false
    )

    internal static let defaultApplePaySettings = ApplePaySettings(
        merchantIdentifier: ConfigurationConstants.applePayMerchantIdentifier,
        allowOnboarding: false,
        didAuthorizeSuccessful: true,
        onBeforeSubmitMode: .updateData
    )

    internal static let defaultAnalyticsSettings = AnalyticsSettings(isEnabled: true)
    
    internal static let defaultThemeSettings = ThemeSettings()
    
    fileprivate static func loadConfiguration() -> DemoAppSettings {
        var config = UserDefaults.standard.data(forKey: defaultsKey)
            .flatMap { try? JSONDecoder().decode(DemoAppSettings.self, from: $0) }
            ?? defaultConfiguration

        // Apply external configuration from launch arguments (passed by e2e tests via Base64-encoded JSON)
        if let external = ExternalConfigurationReader.readFromLaunchArguments() {
            config = config.applying(external)
        }

        switch CommandLine.arguments.first {
        case "SG":
            config.countryCode = "SG"
            config.currencyCode = "SGD"
        default:
            return config
        }
        return config
    }
    
    fileprivate static func saveConfiguration(_ configuration: DemoAppSettings) {
        if let configurationData = try? JSONEncoder().encode(configuration) {
            UserDefaults.standard.setValue(configurationData, forKey: defaultsKey)
        }
    }

    internal var cardConfiguration: CardConfiguration {
        CardConfiguration()
            .showCardholderName(cardSettings.showCardholderName)
            .showStorePaymentMethod(cardSettings.showStorePaymentMethod)
            .showSecurityCode(cardSettings.showSecurityCode)
            .koreanAuthenticationVisibility(cardSettings.koreanAuthenticationVisibility)
            .socialSecurityNumberVisibility(cardSettings.socialSecurityNumberVisibility)
            .showSecurityCodeForStoredCard(cardSettings.showSecurityCodeForStoredCard)
            .installmentConfiguration(installmentConfiguration)
            .billingAddressMode(billingAddressMode(from: cardSettings.addressMode))
    }

    internal var cardDropInConfiguration: DropInComponent.Card {
        .init(
            showCardholderName: cardSettings.showCardholderName,
            showStorePaymentMethod: cardSettings.showStorePaymentMethod,
            showSecurityCode: cardSettings.showSecurityCode,
            koreanAuthenticationVisibility: cardSettings.koreanAuthenticationVisibility,
            socialSecurityNumberVisibility: cardSettings.socialSecurityNumberVisibility,
            showSecurityCodeForStoredCard: cardSettings.showSecurityCodeForStoredCard,
            installmentConfiguration: installmentConfiguration
        )
    }

    internal var dropInConfiguration: DropInComponent.Configuration {
        var style = DropInComponent.Style()
        style.navigation.tintColor = .red

        let theme = themeSettings.theme.theme

        let dropInConfig = DropInComponent.Configuration(
            style: style,
            theme: theme,
            allowsSkippingPaymentList: dropInSettings.allowsSkippingPaymentList,
            allowPreselectedPaymentView: dropInSettings.allowPreselectedPaymentView
        )

        dropInConfig.paymentMethodsList.allowDisablingStoredPaymentMethods = dropInSettings.allowDisablingStoredPaymentMethods
        dropInConfig.cashAppPay = .init(redirectURL: ConfigurationConstants.returnUrl)
        dropInConfig.actionComponent.twint = .init(callbackAppScheme: ConfigurationConstants.returnUrl.scheme!)

        return dropInConfig
    }

    internal func applePayConfiguration(using request: PKPaymentRequest) throws -> ApplePayConfiguration {
        try ApplePayConfiguration(paymentRequest: request)
            .allowOnboarding(applePaySettings.allowOnboarding)
    }

    internal var analyticsConfiguration: AnalyticsConfiguration {
        AnalyticsConfiguration(
            isEnabled: ConfigurationConstants.current.analyticsSettings.isEnabled
        )
    }

}

private extension DemoAppSettings {
    
    private func billingAddressMode(from addressFormType: CardSettings.AddressFormType) -> BillingAddressMode {
        switch addressFormType {
        case .lookup:
            let provider = DemoAddressLookupProvider()
            return .lookup(
                onAddressLookup: { searchTerm in
                    await provider.searchAsync(searchTerm)
                },
                onAddressSelected: { selected in
                    try await provider.completeAsync(selected)
                }
            )
        case .lookupMapKit:
            let provider = MapkitAddressLookupProvider()
            return .lookup(
                onAddressLookup: { searchTerm in
                    await provider.searchAsync(searchTerm)
                }
            )
        case .full:
            return .full
        case .postalCode:
            return .postalCode
        case .none:
            return .none
        }
    }
}

internal extension PKPaymentRequest {
    
    static var demo: PKPaymentRequest {
        let amount = ConfigurationConstants.current.amount
        let decimalAmount = AmountFormatter.decimalAmount(
            amount.value,
            currencyCode: amount.currencyCode,
            localeIdentifier: amount.localeIdentifier
        )

        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = ConfigurationConstants.current.applePaySettings.merchantIdentifier
        paymentRequest.countryCode = ConfigurationConstants.current.countryCode
        paymentRequest.currencyCode = amount.currencyCode
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: ConfigurationConstants.appName, amount: decimalAmount)
        ]
        paymentRequest.merchantCapabilities = [.capability3DS, .credit, .debit]
        return paymentRequest
    }
    
    static var demoWithShippingFields: PKPaymentRequest {
        let amount = ConfigurationConstants.current.amount
        let decimalAmount = AmountFormatter.decimalAmount(
            amount.value,
            currencyCode: amount.currencyCode,
            localeIdentifier: amount.localeIdentifier
        )

        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = ConfigurationConstants.current.applePaySettings.merchantIdentifier
        paymentRequest.countryCode = ConfigurationConstants.current.countryCode
        paymentRequest.currencyCode = amount.currencyCode
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: ConfigurationConstants.appName, amount: decimalAmount)
        ]
        paymentRequest.merchantCapabilities = [.capability3DS, .credit, .debit]
        paymentRequest.shippingType = .delivery
        paymentRequest.requiredShippingContactFields = [.postalAddress]
        paymentRequest.requiredBillingContactFields = [.postalAddress]
        paymentRequest.shippingMethods = ConfigurationConstants.shippingMethods
        paymentRequest.supportsCouponCode = true
        return paymentRequest
    }
}
