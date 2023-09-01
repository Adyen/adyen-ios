//
// Copyright (c) 2023 Adyen N.V.
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

enum ConfigurationConstants {
    // swiftlint:disable explicit_acl
    // swiftlint:disable line_length

    /// Please use your own web server between your app and adyen checkout API.
    static let demoServerEnvironment = DemoCheckoutAPIEnvironment.test
    
    static let classicAPIEnvironment = DemoClassicAPIEnvironment.test

    static let componentsEnvironment = Environment.test

    static let appName = "Adyen Demo"

    static let reference = "Test Order Reference - iOS UIHost"

    static let returnUrl = "ui-host://payments"
    
    static let shopperReference = "iOS Checkout Shopper"

    static let shopperEmail = "checkoutShopperiOS@example.org"
    
    static let additionalData = ["allow3DS2": true, "executeThreeD": true]
    
    static let recurringProcessingModel = "CardOnFile"

    static var apiContext: APIContext {
        if let apiContext = try? APIContext(environment: componentsEnvironment, clientKey: clientKey) {
            return apiContext
        }
        // swiftlint:disable:next force_try
        return try! APIContext(environment: componentsEnvironment, clientKey: "local_DUMMYKEYFORTESTING")
    }

    static let clientKey = "{YOUR_CLIENT_KEY}"

    static let demoServerAPIKey = "{YOUR_DEMO_SERVER_API_KEY}"

    static let merchantAccount = "{YOUR_MERCHANT_ACCOUNT}"

    static let appleTeamIdentifier = "{YOUR_APPLE_DEVELOPMENT_TEAM_ID}"

    static let applePayMerchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"

    static let lineItems = [["description": "Socks",
                             "quantity": "2",
                             "amountIncludingTax": "300",
                             "amountExcludingTax": "248",
                             "taxAmount": "52",
                             "id": "Item #2"]]
    static var delegatedAuthenticationConfigurations: ThreeDS2Component.Configuration.DelegatedAuthentication {
        .init(localizedRegistrationReason: "Authenticate your card!",
              localizedAuthenticationReason: "Register this device!",
              appleTeamIdentifier: appleTeamIdentifier)
        
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

struct CardComponentConfiguration: Codable {
    var showsHolderNameField = false
    var showsStorePaymentMethodField = true
    var showsStoredCardSecurityCodeField = true
    var showsSecurityCodeField = true
    var addressMode: AddressFormType = .none
    var socialSecurityNumberMode: CardComponent.FieldVisibility = .auto
    var koreanAuthenticationMode: CardComponent.FieldVisibility = .auto
    
    enum AddressFormType: String, Codable, CaseIterable {
        case lookup
        case full
        case postalCode
        case none
    }
}

struct DropInConfiguration: Codable {
    var allowDisablingStoredPaymentMethods: Bool = false
    var allowsSkippingPaymentList: Bool = false
    var allowPreselectedPaymentView: Bool = true
}

struct ApplePayConfiguration: Codable {
    var merchantIdentifier: String
    var allowOnboarding: Bool = false
}

struct AnalyticConfiguration: Codable {
    var isEnabled: Bool = true
}

struct DemoAppSettings: Codable {
    private static let defaultsKey = "ConfigurationKey"
    
    var countryCode: String
    let value: Int
    var currencyCode: String
    let apiVersion: Int
    let merchantAccount: String
    let cardComponentConfiguration: CardComponentConfiguration
    let dropInConfiguration: DropInConfiguration
    let applePayConfiguration: ApplePayConfiguration
    let analyticsConfiguration: AnalyticConfiguration

    var amount: Amount { Amount(value: value, currencyCode: currencyCode, localeIdentifier: nil) }
    var payment: Payment { Payment(amount: amount, countryCode: countryCode) }
    
    static let defaultConfiguration = DemoAppSettings(
        countryCode: "NL",
        value: 17408,
        currencyCode: "EUR",
        apiVersion: 70,
        merchantAccount: ConfigurationConstants.merchantAccount,
        cardComponentConfiguration: defaultCardComponentConfiguration,
        dropInConfiguration: defaultDropInConfiguration,
        applePayConfiguration: defaultApplePayConfiguration,
        analyticsConfiguration: defaultAnalyticsConfiguration
    )

    static let defaultCardComponentConfiguration = CardComponentConfiguration(showsHolderNameField: false,
                                                                              showsStorePaymentMethodField: true,
                                                                              showsStoredCardSecurityCodeField: true,
                                                                              showsSecurityCodeField: true,
                                                                              addressMode: .none,
                                                                              socialSecurityNumberMode: .auto,
                                                                              koreanAuthenticationMode: .auto)

    static let defaultDropInConfiguration = DropInConfiguration(allowDisablingStoredPaymentMethods: false,
                                                                allowsSkippingPaymentList: false,
                                                                allowPreselectedPaymentView: true)

    static let defaultApplePayConfiguration = ApplePayConfiguration(merchantIdentifier: ConfigurationConstants.applePayMerchantIdentifier,
                                                                    allowOnboarding: false)

    static let defaultAnalyticsConfiguration = AnalyticConfiguration(isEnabled: true)
    
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

    var cardConfiguration: CardComponent.Configuration {
        var storedCardConfig = StoredCardConfiguration()
        storedCardConfig.showsSecurityCodeField = cardComponentConfiguration.showsStoredCardSecurityCodeField

        var billingAddressConfig = BillingAddressConfiguration()
        billingAddressConfig.mode = cardComponentAddressFormType(from: cardComponentConfiguration.addressMode)

        return .init(showsHolderNameField: cardComponentConfiguration.showsHolderNameField,
                     showsStorePaymentMethodField: cardComponentConfiguration.showsStorePaymentMethodField,
                     showsSecurityCodeField: cardComponentConfiguration.showsSecurityCodeField,
                     koreanAuthenticationMode: cardComponentConfiguration.koreanAuthenticationMode,
                     socialSecurityNumberMode: cardComponentConfiguration.socialSecurityNumberMode,
                     storedCardConfiguration: storedCardConfig,
                     billingAddress: billingAddressConfig)
    }

    var cardDropInConfiguration: DropInComponent.Card {
        var storedCardConfig = StoredCardConfiguration()
        storedCardConfig.showsSecurityCodeField = cardComponentConfiguration.showsStoredCardSecurityCodeField

        var billingAddressConfig = BillingAddressConfiguration()
        billingAddressConfig.mode = cardComponentAddressFormType(from: cardComponentConfiguration.addressMode)

        return .init(showsHolderNameField: cardComponentConfiguration.showsHolderNameField,
                     showsStorePaymentMethodField: cardComponentConfiguration.showsStorePaymentMethodField,
                     showsSecurityCodeField: cardComponentConfiguration.showsSecurityCodeField,
                     koreanAuthenticationMode: cardComponentConfiguration.koreanAuthenticationMode,
                     socialSecurityNumberMode: cardComponentConfiguration.socialSecurityNumberMode,
                     storedCardConfiguration: storedCardConfig,
                     billingAddress: billingAddressConfig)

    }

    var dropInSettings: DropInComponent.Configuration {
        let dropInConfig = DropInComponent.Configuration(allowsSkippingPaymentList: dropInConfiguration.allowsSkippingPaymentList,
                                                         allowPreselectedPaymentView: dropInConfiguration.allowPreselectedPaymentView)

        dropInConfig.paymentMethodsList.allowDisablingStoredPaymentMethods = dropInConfiguration.allowDisablingStoredPaymentMethods

        return dropInConfig
    }

    var applePaySettings: ApplePayComponent.Configuration? {
        do {
            let applePayPayment = try ApplePayPayment(payment: ConfigurationConstants.current.payment,
                                                      brand: ConfigurationConstants.appName)
            var config = ApplePayComponent.Configuration(payment: applePayPayment,
                                                         merchantIdentifier:
                                                         ConfigurationConstants.current.applePayConfiguration.merchantIdentifier)
            config.allowOnboarding = applePayConfiguration.allowOnboarding
            return config
        } catch {
            AdyenAssertion.assertionFailure(message: error.localizedDescription)
        }
        return nil
    }

    var analyticsSettings: AnalyticsConfiguration {
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = ConfigurationConstants.current.analyticsConfiguration.isEnabled
        return analyticsConfiguration
    }

}

private extension DemoAppSettings {
    
    private func cardComponentAddressFormType(from addressFormType: CardComponentConfiguration.AddressFormType) -> CardComponent.AddressFormType {
        switch addressFormType {
        case .lookup:
            let addressLookupProvider = DemoAddressLookupProvider()
            return .lookup { searchTerm, completionHandler in
                addressLookupProvider.lookUp(searchTerm: searchTerm, resultHandler: completionHandler)
            }
        case .full:
            return .full
        case .postalCode:
            return .postalCode
        case .none:
            return .none
        }
    }
}
