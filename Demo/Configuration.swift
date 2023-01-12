//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenActions
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
    
    static var current = Configuration.loadConfiguration() {
        didSet { Configuration.saveConfiguration(current) }
    }

    // swiftlint:enable explicit_acl
    // swiftlint:enable line_length
}

internal struct Configuration: Codable {
    private static let defaultsKey = "ConfigurationKey"
    
    internal var countryCode: String
    internal let value: Int
    internal var currencyCode: String
    internal let apiVersion: Int
    internal let merchantAccount: String
    
    internal var amount: Amount { Amount(value: value, currencyCode: currencyCode, localeIdentifier: nil) }
    internal var payment: Payment { Payment(amount: amount, countryCode: countryCode) }
    
    internal static let defaultConfiguration = Configuration(
        countryCode: "NL",
        value: 17408,
        currencyCode: "EUR",
        apiVersion: 68,
        merchantAccount: ConfigurationConstants.merchantAccount
    )
    
    fileprivate static func loadConfiguration() -> Configuration {
        var config = UserDefaults.standard.data(forKey: defaultsKey)
            .flatMap { try? JSONDecoder().decode(Configuration.self, from: $0) }
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
    
    fileprivate static func saveConfiguration(_ configuration: Configuration) {
        if let configurationData = try? JSONEncoder().encode(configuration) {
            UserDefaults.standard.setValue(configurationData, forKey: defaultsKey)
        }
    }
    
}
