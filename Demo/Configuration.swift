//
// Copyright (c) 2017 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import AdyenDropIn
import Foundation
import PassKit

internal enum ConfigurationConstants {
    // swiftlint:disable explicit_acl
    // swiftlint:disable line_length
    
    /// Please use your own web server between your app and adyen checkout API.
    static let demoServerEnvironment = DemoCheckoutAPIEnvironment.test
    
    static let classicAPIEnvironment = DemoClassicAPIEnvironment.test
    
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
    
    static var delegatedAuthenticationConfigurations: ThreeDS2Component.Configuration.DelegatedAuthentication {
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
    internal var showsHolderNameField = false
    internal var showsStorePaymentMethodField = true
    internal var showsStoredCardSecurityCodeField = true
    internal var showsSecurityCodeField = true
    internal var addressMode: AddressFormType = .none
    internal var socialSecurityNumberMode: CardComponent.FieldVisibility = .auto
    internal var koreanAuthenticationMode: CardComponent.FieldVisibility = .auto
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
}

internal struct AnalyticsSettings: Codable {
    internal var isEnabled: Bool = true
}

internal struct DemoAppSettings: Codable {
    private static let defaultsKey = "ConfigurationKey"
    
    internal var countryCode: String
    internal let value: Int
    internal var currencyCode: String
    internal let apiVersion: Int
    internal let merchantAccount: String
    internal let cardSettings: CardSettings
    internal let dropInSettings: DropInSettings
    internal let threeDSConfigurationSettings: ThreeDSConfigurationSettings
    internal let applePaySettings: ApplePaySettings
    internal let analyticsSettings: AnalyticsSettings

    internal var amount: Amount {
        Amount(value: value, currencyCode: currencyCode, localeIdentifier: nil)
    }

    internal var payment: Payment {
        Payment(amount: amount, countryCode: countryCode)
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
        apiVersion: 71,
        merchantAccount: ConfigurationConstants.merchantAccount,
        cardSettings: defaultCardSettings,
        dropInSettings: defaultDropInSettings,
        threeDSConfigurationSettings: threeDSConfigurationSettings,
        applePaySettings: defaultApplePaySettings,
        analyticsSettings: defaultAnalyticsSettings
    )

    internal static let defaultCardSettings = CardSettings(
        showsHolderNameField: false,
        showsStorePaymentMethodField: true,
        showsStoredCardSecurityCodeField: true,
        showsSecurityCodeField: true,
        addressMode: .none,
        socialSecurityNumberMode: .auto,
        koreanAuthenticationMode: .auto,
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
        didAuthorizeSuccessful: true
    )

    internal static let defaultAnalyticsSettings = AnalyticsSettings(isEnabled: true)
    
    fileprivate static func loadConfiguration() -> DemoAppSettings {
        var config = UserDefaults.standard.data(forKey: defaultsKey)
            .flatMap { try? JSONDecoder().decode(DemoAppSettings.self, from: $0) }
            ?? defaultConfiguration
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

    internal var cardConfiguration: CardComponent.Configuration {
        var storedCardConfig = StoredCardConfiguration()
        storedCardConfig.showsSecurityCodeField = cardSettings.showsStoredCardSecurityCodeField

        var billingAddressConfig = BillingAddressConfiguration()
        billingAddressConfig.mode = cardComponentAddressFormType(from: cardSettings.addressMode)
        
        let style = FormComponentStyle()

        return .init(
            style: style,
            showsHolderNameField: cardSettings.showsHolderNameField,
            showsStorePaymentMethodField: cardSettings.showsStorePaymentMethodField,
            showsSecurityCodeField: cardSettings.showsSecurityCodeField,
            koreanAuthenticationMode: cardSettings.koreanAuthenticationMode,
            socialSecurityNumberMode: cardSettings.socialSecurityNumberMode,
            storedCardConfiguration: storedCardConfig,
            installmentConfiguration: installmentConfiguration,
            billingAddress: billingAddressConfig
        )
    }

    internal var cardDropInConfiguration: DropInComponent.Card {
        var storedCardConfig = StoredCardConfiguration()
        storedCardConfig.showsSecurityCodeField = cardSettings.showsStoredCardSecurityCodeField

        var billingAddressConfig = BillingAddressConfiguration()
        billingAddressConfig.mode = cardComponentAddressFormType(from: cardSettings.addressMode)

        return .init(
            showsHolderNameField: cardSettings.showsHolderNameField,
            showsStorePaymentMethodField: cardSettings.showsStorePaymentMethodField,
            showsSecurityCodeField: cardSettings.showsSecurityCodeField,
            koreanAuthenticationMode: cardSettings.koreanAuthenticationMode,
            socialSecurityNumberMode: cardSettings.socialSecurityNumberMode,
            storedCardConfiguration: storedCardConfig,
            installmentConfiguration: installmentConfiguration,
            billingAddress: billingAddressConfig
        )

    }

    internal var dropInConfiguration: DropInComponent.Configuration {
        var style = DropInComponent.Style()
        style.navigation.tintColor = .red
        
        let dropInConfig = DropInComponent.Configuration(
            style: style,
            allowsSkippingPaymentList: dropInSettings.allowsSkippingPaymentList,
            allowPreselectedPaymentView: dropInSettings.allowPreselectedPaymentView
        )

        dropInConfig.paymentMethodsList.allowDisablingStoredPaymentMethods = dropInSettings.allowDisablingStoredPaymentMethods
        dropInConfig.cashAppPay = .init(redirectURL: ConfigurationConstants.returnUrl)
        dropInConfig.actionComponent.twint = .init(callbackAppScheme: ConfigurationConstants.returnUrl.scheme!)

        return dropInConfig
    }

    internal func applePayConfiguration() throws -> ApplePayComponent.Configuration {
        let applePayPayment = try ApplePayPayment(
            payment: ConfigurationConstants.current.payment,
            brand: ConfigurationConstants.appName
        )
        var config = ApplePayComponent.Configuration(
            payment: applePayPayment,
            merchantIdentifier:
            ConfigurationConstants.current.applePaySettings.merchantIdentifier
        )
        config.allowOnboarding = applePaySettings.allowOnboarding
        return config
    }

    internal var analyticsConfiguration: AnalyticsConfiguration {
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = ConfigurationConstants.current.analyticsSettings.isEnabled
        return analyticsConfiguration
    }

}

private extension DemoAppSettings {
    
    private func cardComponentAddressFormType(from addressFormType: CardSettings.AddressFormType) -> CardComponent.AddressFormType {
        switch addressFormType {
        case .lookup:
            return .lookup(provider: DemoAddressLookupProvider())
        case .lookupMapKit:
            return .lookup(provider: MapkitAddressLookupProvider())
        case .full:
            return .full
        case .postalCode:
            return .postalCode
        case .none:
            return .none
        }
    }
}
