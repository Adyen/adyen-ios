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
    static let demoServerEnvironment = DemoServerEnvironment.test

    static let componentsEnvironment = Environment.test

    static let appName = "Adyen Demo"

    static let reference = "Test Order Reference - iOS UIHost"

    static let returnUrl = "ui-host://"
    
    static let shopperReference = "iOS Checkout Shopper"

    static let shopperEmail = "checkoutshopperios@example.org"
    
    static let additionalData = ["allow3DS2": true]

    static let clientKey = "test_I7ABUXA66FCC5OG3FNVMKPVYDIXSYTLR"
    
    static let apiContext = APIContext(environment: componentsEnvironment, clientKey: clientKey)

    // swiftlint:disable:next line_length
    static let demoServerAPIKey = "AQEphmfuXNWTK0Qc+iSDgm02hueYR55DGcMTDWlE1rNRjS1UduCj/CcjoG4QwV1bDb7kfNy1WIxIIkxgBw==-HVMl6ri9a3R23e5A3zeRll3j3ztqGuuDu290HGCqqsw=-p5)54AtT#@d9_8PU"

	static let applePayMerchantIdentifier = "merchant.pm.spin"
    
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
        merchantAccount: "SpinUS"
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
