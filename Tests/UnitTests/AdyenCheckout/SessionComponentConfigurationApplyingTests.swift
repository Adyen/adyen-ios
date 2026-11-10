//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenComponents
@testable import AdyenUI
import XCTest

@MainActor
final class SessionComponentConfigurationApplyingTests: XCTestCase {

    func test_cardConfiguration_applyingSession_overridesStorePaymentMethodAndInstallments() {
        let sessionInstallments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallments: 6, plans: [.regular, .revolving])
        )
        let configuration = CardConfiguration()
            .showStorePaymentMethod(true)
            .installmentConfiguration(InstallmentConfiguration(defaultOptions: InstallmentOptions(maxInstallments: 3)))

        let result = configuration.applying(
            SessionComponentConfiguration(installmentConfiguration: sessionInstallments, showStorePaymentMethod: false)
        )

        XCTAssertFalse(result.showStorePaymentMethod)
        XCTAssertEqual(result.installmentConfiguration, sessionInstallments)
    }

    func test_cardConfiguration_applyingSessionWithoutInstallments_clearsMerchantInstallments() {
        let configuration = CardConfiguration()
            .installmentConfiguration(InstallmentConfiguration(defaultOptions: InstallmentOptions(maxInstallments: 3)))

        let result = configuration.applying(
            SessionComponentConfiguration(installmentConfiguration: nil, showStorePaymentMethod: true)
        )

        XCTAssertTrue(result.showStorePaymentMethod)
        XCTAssertNil(result.installmentConfiguration)
    }

    func test_cardConfiguration_applyingSession_preservesOtherSettings() {
        let configuration = CardConfiguration()
            .showCardholderName(true)
            .showSecurityCode(false)

        let result = configuration.applying(
            SessionComponentConfiguration(installmentConfiguration: nil, showStorePaymentMethod: false)
        )

        XCTAssertTrue(result.showCardholderName)
        XCTAssertFalse(result.showSecurityCode)
    }

    func test_achConfiguration_applyingSession_overridesStorePaymentMethod() {
        let configuration = ACHDirectDebitConfiguration()
            .showStorePaymentMethod(true)
            .showBillingAddress(false)

        let result = configuration.applying(
            SessionComponentConfiguration(installmentConfiguration: nil, showStorePaymentMethod: false)
        )

        XCTAssertFalse(result.showStorePaymentMethod)
        XCTAssertFalse(result.showBillingAddress)
    }

    func test_applyingSession_throughGenericConfiguration_usesConformingTypeImplementation() {
        let session = SessionComponentConfiguration(installmentConfiguration: nil, showStorePaymentMethod: false)

        let card = applyGeneric(session, to: CardConfiguration().showStorePaymentMethod(true))
        let ach = applyGeneric(session, to: ACHDirectDebitConfiguration().showStorePaymentMethod(true))

        XCTAssertFalse(card.showStorePaymentMethod)
        XCTAssertFalse(ach.showStorePaymentMethod)
    }

    func test_applyingSession_withoutSessionSettings_returnsConfigurationUnchanged() {
        var configuration = BasicComponentConfiguration()
        configuration.showsSubmitButton = false

        let result = applyGeneric(
            SessionComponentConfiguration(installmentConfiguration: nil, showStorePaymentMethod: true),
            to: configuration
        )

        XCTAssertFalse(result.showsSubmitButton)
    }

    private func applyGeneric<Configuration: CheckoutComponentConfiguration>(
        _ session: SessionComponentConfiguration,
        to configuration: Configuration
    ) -> Configuration {
        configuration.applying(session)
    }
}
