//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

internal enum Configuration {
    // swiftlint:disable explicit_acl

    /// Please use your own web server between your app and adyen checkout API.
    static let demoServerEnvironment = DemoServerEnvironment.test

    static let componentsEnvironment = Environment.test

    static let appName = "Adyen Demo"

    static let amount = Payment.Amount(value: 17408, currencyCode: "EUR")

    static let reference = "Test Order Reference - iOS UIHost"
    
    static let countryCode = "NL"

    static let returnUrl = "ui-host://"
    
    static let shopperReference = "iOS Checkout Shopper"

    static let merchantAccount = "TestMerchantCheckout"

    static let shopperEmail = "checkoutshopperios@example.org"
    
    static let additionalData = ["allow3DS2": true]

    static let clientKey = "{YOUR_CLIENT_KEY}"

    // swiftlint:disable:next line_length
    static let demoServerAPIKey = "{YOUR_DEMO_SERVER_API_KEY}"
    
    static let applePayMerchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"
    
    static let applePaySummaryItems = [
        PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)
    ]

    // swiftlint:enable explicit_acl
    
}
