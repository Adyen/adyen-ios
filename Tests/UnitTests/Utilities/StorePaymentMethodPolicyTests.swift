//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import Testing

struct StorePaymentMethodPolicyTests {

    @Test(arguments: [
        (Amount(value: 0, currencyCode: "EUR"), true, false),
        (Amount(value: 0, currencyCode: "EUR"), false, false),
        (Amount(value: 100, currencyCode: "EUR"), true, true),
        (Amount(value: 100, currencyCode: "EUR"), false, false)
    ])
    func amountAndConfiguration_whenResolvingConsentVisibility_thenReturnsExpectedResult(
        amount: Amount?,
        configuredVisible: Bool,
        expectedResult: Bool
    ) {
        #expect(StorePaymentMethodPolicy.shouldShowConsent(
            configuredVisible: configuredVisible,
            amount: amount
        ) == expectedResult)
    }

    @Test(arguments: [
        (true, true),
        (false, false)
    ])
    func nilAmount_whenResolvingConsentVisibility_thenPreservesConfiguration(
        configuredVisible: Bool,
        expectedResult: Bool
    ) {
        #expect(StorePaymentMethodPolicy.shouldShowConsent(
            configuredVisible: configuredVisible,
            amount: nil
        ) == expectedResult)
    }

}
