//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenComponents
import AdyenEncryption
import Foundation
import PassKit

enum Dummy: Error {
    case error

    internal static let payment = Payment(amount: Amount(value: 100, currencyCode: "EUR"), countryCode: "NL")
    
    /// This is not a real public key, this is just a random string with the right pattern.
    internal static let publicKey = "9E1CB|B2BCED4E13103C5983A9B09D63DE84ACC0183D40D0E187DAE2A4390BA63BBFF209FF0C122044B826697C71391E5D5C1449F9C248E47DBB5BEEBCD72D4167F46CD6BBCEBB4E53DB440A86F4C00E155DF4813ABE04D019D6D85BE34044D585A6EE4CF527171EBCB985DA7403AAA762F7358093575A529251DD4D9009471269AC21DD311A29EAD64B1AE809E1F0C74486787FCBBBEBBB2F3573DF6F011566982A49EA96E959215BA6584B61A0CEDD3322AE9D67EE954CA8644851894B85C971982467F1DD0054508DCF3AE74ABB8E6F54DBF2A8ABB6B3CCBB0BD5637DA93200891918D65F9C4D399AABDA94F7CE8125C9B35DE9398DF51CC11E385F951C0B4D8EBD"
    
    internal static let apiContext = try! APIContext(environment: Environment.test, clientKey: "local_DUMMYKEYFORTESTING")

    internal static var context: AdyenContext {
        AdyenContext(apiContext: apiContext, payment: payment)
    }

    internal static func context(with payment: Payment?) -> AdyenContext {
        AdyenContext(apiContext: apiContext, payment: payment)
    }

    internal static let visaCard = Card(number: "4917 6100 0000 0000",
                                        securityCode: "737",
                                        expiryMonth: "03",
                                        expiryYear: "30",
                                        holder: nil)

    internal static let amexCard = Card(number: "3714 4963 5398 431",
                                        securityCode: "737",
                                        expiryMonth: "03",
                                        expiryYear: "30",
                                        holder: nil)

    internal static let bancontactCard = Card(number: "6703 4444 4444 4449",
                                              securityCode: nil,
                                              expiryMonth: "03",
                                              expiryYear: "30",
                                              holder: nil)
    
    internal static let longBancontactCard = Card(number: "6703 0000 0000 0000 003",
                                                  securityCode: nil,
                                                  expiryMonth: "03",
                                                  expiryYear: "30",
                                                  holder: nil)

    internal static let kcpCard = Card(number: "9490 2200 0661 1406",
                                       securityCode: "637",
                                       expiryMonth: "03",
                                       expiryYear: "30",
                                       holder: nil)

    internal static func createTestApplePayPayment() -> ApplePayPayment {
        try! .init(countryCode: "US", currencyCode: "USD", summaryItems: createTestSummaryItems())
    }
    
    internal static let returnUrl = URL(string: "https://google.com?redirectResult=some")!

    internal static func createTestSummaryItems() -> [PKPaymentSummaryItem] {
        var amounts = (0...3).map { _ in
            NSDecimalNumber(mantissa: UInt64.random(in: 1...20), exponent: 1, isNegative: Bool.random())
        }
        // Positive Grand total
        amounts.append(NSDecimalNumber(mantissa: 20, exponent: 1, isNegative: false))
        return amounts.enumerated().map {
            PKPaymentSummaryItem(label: "summary_\($0)", amount: $1)
        }
    }

}
