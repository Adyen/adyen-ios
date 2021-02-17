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
    static let demoServerEnvironment = DemoServerEnvironment.local

    static let local = Environment(baseURL: URL(string: "http://localhost:8080/")!)

    static let componentsEnvironment = local

    static let appName = "Adyen Demo"

    static let amount = Payment.Amount(value: 17408, currencyCode: "IDR")

    static let reference = "Test Order Reference - iOS UIHost"
    
    static let countryCode = "ID"

    static let returnUrl = "ui-host://"
    
    static let shopperReference = "iOS Checkout Shopper"

    static let merchantAccount = "TestMerchant"

    static let shopperEmail = "checkoutshopperios@example.org"
    
    static let additionalData = ["allow3DS2": true]
    
    static let clientKey = "test_L6HTEOAXQBCZJHKNU4NLN6EI7IE6VRRW"

    // swiftlint:disable:next line_length
    static let demoServerAPIKey = "AQEthmfxKo7MbhFLw0m/n3Q5qf3VfI5eGbBFVXVXyGHNhisxSHQZLQhnJZKhUXeVEMFdWw2+5HzctViMSCJMYAc=-iLjeIbd8YjLi4aPYhovzGTmJkrNSaNExFw267yN7eYY=-t4aYUIMHdBz6MudS"
    
    static let applePayMerchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"
    
    static let applePaySummaryItems = [
        PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)
    ]

    // swiftlint:enable explicit_acl
    
}
