//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

@MainActor
final class CardComponentFactoryTests: XCTestCase {

    private var context: AdyenContext!

    override func setUp() {
        super.setUp()
        context = Dummy.context
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func test_create_withSessionConfiguration_appliesSessionOverrides() throws {
        let paymentMethod = try XCTUnwrap(createCardPaymentMethod())
        let merchantInstallments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallmentMonth: 3, includesRevolving: false)
        )
        let sessionInstallments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallmentMonth: 6, includesRevolving: true)
        )
        let configuration = CardConfiguration()
            .showStorePaymentMethod(true)
            .installmentConfiguration(merchantInstallments)
        let factory = CardComponentFactory<CardPaymentMethod>(
            sessionConfiguration: .init(
                installmentConfiguration: sessionInstallments,
                showStorePaymentMethod: false
            )
        )

        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        XCTAssertFalse(component.configuration.showStorePaymentMethod)
        XCTAssertEqual(component.configuration.installmentConfiguration, sessionInstallments)
    }

    func test_create_withoutSessionConfiguration_preservesConfiguration() throws {
        let paymentMethod = try XCTUnwrap(createCardPaymentMethod())
        let merchantInstallments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallmentMonth: 3, includesRevolving: false)
        )
        let configuration = CardConfiguration()
            .showStorePaymentMethod(false)
            .installmentConfiguration(merchantInstallments)
        let factory = CardComponentFactory<CardPaymentMethod>()

        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        XCTAssertFalse(component.configuration.showStorePaymentMethod)
        XCTAssertEqual(component.configuration.installmentConfiguration, merchantInstallments)
    }

    private func createCardPaymentMethod() -> CardPaymentMethod? {
        let dictionary: [String: Any] = [
            "type": "scheme",
            "name": "Cards",
            "brands": ["mc", "visa"]
        ]
        return try? AdyenCoder.decode(dictionary) as CardPaymentMethod
    }
}
