//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

internal struct Configuration {
    // swiftlint:disable explicit_acl
    
    static let environment = DemoServerEnvironment.test
    
    static let appName = "Adyen Demo"
    
    static let amount = Payment.Amount(value: 17408, currencyCode: "EUR")
    
    static let reference = "Test Order Reference - iOS UIHost"
    
    static let countryCode = "NL"
    
    static let returnUrl = "ui-host://"
    
    static let shopperReference = "iOS Checkout Shopper"
    
    static let shopperEmail = "checkoutshopperios@example.org"
    
    static let additionalData = ["allow3DS2": true]
    
    static let clientKey = "test_Y7PWSUZA7BGLXHROFDENCUQEG4L24VSE"
    
    // swiftlint:disable:next line_length
    static let cardPublicKey = "10001|AB899C86A40BDEEF30F70BD8E472B9DC85ADA3514548482E11E35AE58F43DD3D190CB480CB7C90AB49C9D8414E29CA33487B97CF1BA3A197D5167CF5AF13E6797CD361C2DCF45964758B36F15D3BF66599C0B572C99FFCF8884595772BE774E5A77A7F058C8F71562FE189BA18ADFF7562278E82FC32587A68C2DCAA3216440F1C84640F1CC6F45CE7A380C1DCB1C83F739EFC10F5EC927D27BE975960CB1177F39025AAC49B721D4DD2E5811FA9CCAF36EBFC733B2E3C1300E4347AEB33611F7CFC320329A23D9DF45B38E99FDAA82C38DF9385D0D90121CF25947F65C35C3D979C33E7A757298C22EC9B9D2159692E2C0F4A5BFFC0CE75CBEFE2B6CF19401B"
    
    // swiftlint:disable:next line_length
    static let demoServerAPIKey = "0101408667EE5CD5932B441CFA248497772C84EB96588A4314DE5E5D76428B4CAE8D72669BD57518C76F1214690BF3F3CC998122A6BC05A182EF9B833E6E5C17C53F3710C15D5B0DBEE47CDCB5588C48224C6007"
    
    static let applePayMerchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"
    
    static let applePaySummaryItems = [
        PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "174.08"), type: .final)
    ]
    
    // swiftlint:enable explicit_acl
    
}
