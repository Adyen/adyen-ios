//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenCheckout
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Foundation
import XCTest

@MainActor
final class CheckoutComponentBuilderDropInTests: XCTestCase {

    func test_buildDropIn_shouldResolveCheckoutPresentationConfiguration() {
        let provider = DropInBuilderLocalizationProviderMock()
        let theme = CheckoutTheme(colors: CheckoutColors(primary: .yellow))
        var checkoutConfiguration = CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            analyticsApiContext: nil,
            analyticsConfiguration: .init()
        )
        checkoutConfiguration = checkoutConfiguration
            .localizationProvider(provider)
            .theme(theme)
        checkoutConfiguration.dropInConfiguration = DropInConfiguration()
            .hideStoredPaymentMethods(true)

        let dropIn = CheckoutComponentBuilder.buildDropIn(
            paymentMethods: PaymentMethods(regular: [], stored: []),
            configuration: checkoutConfiguration,
            context: Dummy.context,
            actionComponentConfiguration: .init(),
            storedPaymentMethodManagementCapability: nil,
            paymentComponentBuilder: { _ in
                throw CheckoutError(code: .paymentMethodFailure, message: "Not used by this test.")
            }
        )

        XCTAssertTrue(dropIn.configuration.hideStoredPaymentMethods)
        XCTAssertEqual(dropIn.configuration.theme.colors.primary, .yellow)
        XCTAssertTrue(dropIn.configuration.localizationProvider as AnyObject === provider)
        XCTAssertNil(checkoutConfiguration.dropInConfiguration.localizationProvider)
    }
}

private final class DropInBuilderLocalizationProviderMock: CheckoutLocalizationProvider {

    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        nil
    }
}
