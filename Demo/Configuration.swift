//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

internal enum ConfigurationConstants {
    // swiftlint:disable explicit_acl

    /// Please use your own web server between your app and adyen checkout API.
    static let demoServerEnvironment = DemoServerEnvironment.local

    static let componentsEnvironment = Environment(baseURL: URL(string: "http://localhost:8080/")!)

    static let appName = "Adyen Demo"

    static let reference = "Test Order Reference - iOS UIHost"

    static let returnUrl = "ui-host://"
    
    static let shopperReference = "iOS Checkout Shopper"

    static let shopperEmail = "checkoutshopperios@example.org"
    
    static let additionalData = ["allow3DS2": true]
    
    static let clientKey = "devl_F73CCZ4Y7NHFRLC3OMVZHDIVQY47VWFL"
    
    static let apiContext = APIContext(environment: componentsEnvironment, clientKey: clientKey)

    // swiftlint:disable:next line_length
    static let demoServerAPIKey = "AQEmhmfuXNWTK0Qc+iSEl3cshOuWWIpDFNWZ7BldpzFgqjaFCkrORCwQwV1bDb7kfNy1WIxIIkxgBw==-3YcmHFltObXoxB00Qd/TNqph2ohOoIucx00nLRbI21E=-0000000000000000"

    static let applePayMerchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"
    
    static var applePaySummaryItems: [PKPaymentSummaryItem] {
        [
            PKPaymentSummaryItem(
                label: "Total",
                amount: AmountFormatter.decimalAmount(current.amount.value, currencyCode: current.amount.currencyCode),
                type: .final
            )
        ]
    }
    
    static var current = Configuration.loadConfiguration() {
        didSet { Configuration.saveConfiguration(current) }
    }

    // swiftlint:enable explicit_acl
}

internal struct Configuration: Codable {
    private static let defaultsKey = "ConfigurationKey"
    
    internal let countryCode: String
    internal let value: Int
    internal let currencyCode: String
    internal let apiVersion: Int
    internal let merchantAccount: String
    
    internal var amount: Amount { Amount(value: value, currencyCode: currencyCode) }
    internal var payment: Payment { Payment(amount: amount, countryCode: countryCode) }
    
    internal static let defaultConfiguration = Configuration(
        countryCode: "NL",
        value: 17408,
        currencyCode: "EUR",
        apiVersion: 67,
        merchantAccount: "TestMerchantCheckout"
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
