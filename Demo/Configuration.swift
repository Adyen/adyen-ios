//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
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
    
    static let additionalData = ["allow3DS2": true]
    
    static let apiContext = APIContext(environment: componentsEnvironment, clientKey: clientKey)
    
    static let clientKey = "{YOUR_CLIENT_KEY}"

    static let demoServerAPIKey = "{YOUR_DEMO_SERVER_API_KEY}"

    static let applePayMerchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"

    static let merchantAccount = "{YOUR_MERCHANT_ACCOUNT}"
    
    static var applePaySummaryItems: [PKPaymentSummaryItem] {
        [
            PKPaymentSummaryItem(
                label: "Total",
                amount: AmountFormatter.decimalAmount(current.amount.value,
                                                      currencyCode: current.amount.currencyCode,
                                                      localeIdentifier: nil),
                type: .final
            )
        ]
    }
    
    static var current = Configuration.loadConfiguration() {
        didSet { Configuration.saveConfiguration(current) }
    }

    // swiftlint:enable explicit_acl
    // swiftlint:enable line_length
}

struct Configuration: Codable {
    private static let defaultsKey = "ConfigurationKey"
    
    let countryCode: String
    let value: Int
    let currencyCode: String
    let apiVersion: Int
    let merchantAccount: String
    
    var amount: Amount { Amount(value: value, currencyCode: currencyCode, localeIdentifier: nil) }
    var payment: Payment { Payment(amount: amount, countryCode: countryCode) }
    
    static let defaultConfiguration = Configuration(
        countryCode: "NL",
        value: 17408,
        currencyCode: "EUR",
        apiVersion: 68,
        merchantAccount: ConfigurationConstants.merchantAccount
    )
    
    fileprivate static func loadConfiguration() -> Configuration {
        UserDefaults.standard.data(forKey: defaultsKey)
            .flatMap { try? JSONDecoder().decode(Configuration.self, from: $0) }
            ?? defaultConfiguration
    }
    
    fileprivate static func saveConfiguration(_ configuration: Configuration) {
        if let configurationData = try? JSONEncoder().encode(configuration) {
            UserDefaults.standard.setValue(configurationData, forKey: defaultsKey)
        }
    }
    
}
