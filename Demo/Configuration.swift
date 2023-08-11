//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenActions
import AdyenCard
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

    static let applePayMerchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"

    static let merchantAccount = "{YOUR_MERCHANT_ACCOUNT}"

    static let appleTeamIdentifier = "{YOUR_APPLE_DEVELOPMENT_TEAM_ID}"

    static let lineItems = [["description": "Socks",
                             "quantity": "2",
                             "amountIncludingTax": "300",
                             "amountExcludingTax": "248",
                             "taxAmount": "52",
                             "id": "Item #2"]]
    static var delegatedAuthenticationConfigurations: ThreeDS2Component.Configuration.DelegatedAuthentication {
        .init(localizedRegistrationReason: "Register this device!",
              localizedAuthenticationReason: "Authenticate your card!",
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

internal struct CardComponentConfiguration: Codable {
    internal var showsHolderNameField = false
    internal var showsStorePaymentMethodField = true
    internal var showsStoredCardSecurityCodeField = true
    internal var showsSecurityCodeField = true
    internal var addressMode: AddressFormType = .none
    internal var socialSecurityNumberMode: CardComponent.FieldVisibility = .auto
    internal var koreanAuthenticationMode: CardComponent.FieldVisibility = .auto
    
    internal enum AddressFormType: String, Codable, CaseIterable {
        case lookup
        case full
        case postalCode
        case none
    }
}

internal struct DropInConfiguration: Codable {
    internal var allowDisablingStoredPaymentMethods: Bool = false
    internal var allowsSkippingPaymentList: Bool = false
    internal var allowPreselectedPaymentView: Bool = true
}

internal struct DemoAppSettings: Codable {
    private static let defaultsKey = "ConfigurationKey"
    
    internal var countryCode: String
    internal let value: Int
    internal var currencyCode: String
    internal let apiVersion: Int
    internal let merchantAccount: String
    internal let cardComponentConfiguration: CardComponentConfiguration
    internal let dropInConfiguration: DropInConfiguration

    internal var amount: Amount { Amount(value: value, currencyCode: currencyCode, localeIdentifier: nil) }
    internal var payment: Payment { Payment(amount: amount, countryCode: countryCode) }
    
    internal static let defaultConfiguration = DemoAppSettings(
        countryCode: "NL",
        value: 17408,
        currencyCode: "EUR",
        apiVersion: 70,
        merchantAccount: ConfigurationConstants.merchantAccount,
        cardComponentConfiguration: defaultCardComponentConfiguration,
        dropInConfiguration: defaultDropInConfiguration
    )

    internal static let defaultCardComponentConfiguration = CardComponentConfiguration(showsHolderNameField: false,
                                                                                       showsStorePaymentMethodField: true,
                                                                                       showsStoredCardSecurityCodeField: true,
                                                                                       showsSecurityCodeField: true,
                                                                                       addressMode: .none,
                                                                                       socialSecurityNumberMode: .auto,
                                                                                       koreanAuthenticationMode: .auto)

    internal static let defaultDropInConfiguration = DropInConfiguration(allowDisablingStoredPaymentMethods: false,
                                                                         allowsSkippingPaymentList: false,
                                                                         allowPreselectedPaymentView: true)
    
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

    internal var cardDropInConfiguration: DropInComponent.Card {
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

    internal var dropInSettings: DropInComponent.Configuration {
        let dropInConfig = DropInComponent.Configuration(allowsSkippingPaymentList: dropInConfiguration.allowsSkippingPaymentList,
                                                         allowPreselectedPaymentView: dropInConfiguration.allowPreselectedPaymentView)

        dropInConfig.paymentMethodsList.allowDisablingStoredPaymentMethods = dropInConfiguration.allowDisablingStoredPaymentMethods

        return dropInConfig
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
