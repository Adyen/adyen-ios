//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

@MainActor
final class StoredCardComponentFactoryTests: XCTestCase {

    private var context: AdyenContext!

    override func setUp() {
        super.setUp()
        context = Dummy.context
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func test_create_withSecurityCodeForStoredCard_shouldReturnStoredCardComponent() {
        let paymentMethod = storedCardPaymentMethod()
        var configuration = CardConfiguration()
        configuration.showsSubmitButton = false
        configuration = configuration.showSecurityCodeForStoredCard(true)

        let sut = StoredCardComponentFactory()
        let component = sut.create(
            storedCardPaymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            localizationParameters: nil
        )

        XCTAssertTrue(component is StoredCardComponent)
        XCTAssertFalse(component is StoredPaymentMethodComponent)
    }

    func test_create_withoutSecurityCodeForStoredCard_shouldReturnStoredPaymentMethodComponent() {
        let paymentMethod = storedCardPaymentMethod()
        var configuration = CardConfiguration()
        configuration = configuration.showSecurityCodeForStoredCard(false)

        let sut = StoredCardComponentFactory()
        let component = sut.create(
            storedCardPaymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            localizationParameters: nil
        )

        XCTAssertTrue(component is StoredPaymentMethodComponent)
        XCTAssertFalse(component is StoredCardComponent)
    }

    func test_create_shouldPropagateLocalizationParameters() {
        let paymentMethod = storedCardPaymentMethod()
        var configuration = CardConfiguration()
        configuration = configuration.showSecurityCodeForStoredCard(false)
        let localizationParameters = LocalizationParameters(tableName: "TestTable", keySeparator: nil)

        let sut = StoredCardComponentFactory()
        let component = sut.create(
            storedCardPaymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            localizationParameters: localizationParameters
        )

        let localizable = component as? Localizable
        XCTAssertEqual(localizable?.localizationParameters?.tableName, "TestTable")
    }

    private func storedCardPaymentMethod() -> StoredCardPaymentMethod {
        StoredCardPaymentMethod(
            type: .scheme,
            name: "Card",
            identifier: "stored-card-id",
            supportedShopperInteractions: [.shopperPresent],
            brand: .visa,
            lastFour: "1234",
            expiryMonth: "12",
            expiryYear: "30",
            holderName: nil
        )
    }
}
