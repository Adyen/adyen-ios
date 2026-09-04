//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenComponents
@testable import AdyenDropIn
#if canImport(AdyenTwint)
    @testable import AdyenTwint
#endif
import XCTest

@MainActor
class ComponentManagerTests: XCTestCase {

    var paymentMethods: PaymentMethods {
        try! AdyenCoder.decode(dictionary) as PaymentMethods
    }
    
    let dictionary = [
        "storedPaymentMethods": [
            storedCreditCardDictionary,
            storedCreditCardDictionary,
            storedPayPalDictionary,
            storedBcmcDictionary,
            storedACHDictionary,
            storedTwintDictionary,
            storedPayToDictionary
        ],
        "paymentMethods": [
            creditCardDictionary,
            issuerListDictionary,
            issuerListDictionaryWithoutDetailsObject,
            sepaDirectDebitDictionary,
            bcmcCardDictionary,
            applePayDictionary,
            giroPayDictionaryWithOptionalDetails,
            giroPayDictionaryWithNonOptionalDetails,
            weChatQRDictionary,
            weChatSDKDictionary,
            weChatWebDictionary,
            weChatMiniProgramDictionary,
            bcmcMobileQR,
            mbway,
            blik,
            qiwiWallet,
            googlePay,
            dokuWallet,
            econtextStores,
            econtextATM,
            econtextOnline,
            oxxo,
            multibanco,
            boletoBancario,
            boletoBancarioSantander,
            primeiroPayBoleto,
            boletoBancarioItau,
            affirm,
            atome,
            achDirectDebit,
            bacsDirectDebit,
            cashAppPay,
            giftCard,
            mealVoucherSodexo,
            twint,
            payto
        ]
    ]
    
    let numberOfExpectedRegularComponents = 28
    let numberOfExpectedStoredComponent = 7

    var presentationDelegate: PresentationDelegateMock!
    var context: AdyenContext!
    var configuration: DropInConfiguration!

    override func setUpWithError() throws {
        try super.setUpWithError()
        presentationDelegate = PresentationDelegateMock()
        context = Dummy.context
        configuration = DropInConfiguration()
    }

    override func tearDownWithError() throws {
        AdyenAssertion.listener = nil
        presentationDelegate = nil
        context = nil
        configuration = nil
        try super.tearDownWithError()
    }

    func testClientKeyInjectionAndProtocolConformance() {
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        XCTAssertEqual(sut.storedComponents.count, numberOfExpectedStoredComponent)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.storedComponents.filter { $0.context.apiContext.clientKey == Dummy.apiContext.clientKey }.count, numberOfExpectedStoredComponent)
        XCTAssertEqual(sut.regularComponents.filter { $0.context.apiContext.clientKey == Dummy.apiContext.clientKey }.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.regularComponents.filter { $0 is LoadingComponent }.count, 22)
        XCTAssertEqual(sut.regularComponents.filter { $0 is PresentablePaymentComponent }.count, 22)
        XCTAssertEqual(sut.regularComponents.filter { $0 is FinalizableComponent }.count, 0)
    }

    func testVisibleStoredPaymentMethods_excludesMethodsUnsupportedInThePaymentList() throws {
        var paymentMethodsDictionary = dictionary
        var storedPaymentMethods = try XCTUnwrap(paymentMethodsDictionary["storedPaymentMethods"] as? [[String: Any]])
        var unsupportedPaymentMethod = storedCreditCardDictionary
        unsupportedPaymentMethod["id"] = "unsupported-stored-payment-method"
        unsupportedPaymentMethod["supportedShopperInteractions"] = ["ContAuth"]
        storedPaymentMethods.append(unsupportedPaymentMethod)
        paymentMethodsDictionary["storedPaymentMethods"] = storedPaymentMethods
        let paymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        XCTAssertFalse(
            sut.visibleStoredPaymentMethods.contains { $0.identifier == "unsupported-stored-payment-method" }
        )
        XCTAssertEqual(
            sut.visibleStoredPaymentMethods.map(\.identifier),
            sut.storedComponents.compactMap {
                ($0.paymentMethod as? any StoredPaymentMethod)?.identifier
            }
        )
        let storedSection = try XCTUnwrap(sut.sections.first { $0.kind == .stored })
        XCTAssertFalse(
            storedSection.paymentMethods.contains {
                ($0 as? any StoredPaymentMethod)?.identifier == "unsupported-stored-payment-method"
            }
        )
    }

    func testCardPaymentMethod() throws {
        let localizationProvider = DropInLocalizationProviderMock()
        configuration = DropInConfiguration()
        configuration.localizationProvider = localizationProvider
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "scheme" } as? CardComponent)
        XCTAssertTrue(paymentComponent.configuration.localizationProvider as AnyObject === localizationProvider)
    }

    func testBCMCPaymentMethod() throws {
        let localizationProvider = DropInLocalizationProviderMock()
        configuration = DropInConfiguration()
        configuration.localizationProvider = localizationProvider
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "bcmc" } as? BCMCComponent)

        XCTAssertTrue(paymentComponent.configuration.localizationProvider as AnyObject === localizationProvider)
    }

    func testTwintShouldSucceedWithConfig() {
        // Given
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = sut.regularComponents.first { $0.paymentMethod.type.rawValue == "twint" }

        // Then
        #if canImport(AdyenTwint)
            let twintComponent = paymentComponent as? TwintComponent
            XCTAssertNotNil(twintComponent)
        #else
            let twintComponent = paymentComponent as? GenericPaymentComponent
            XCTAssertNil(twintComponent)
        #endif
    }

    func testStoredTwintShouldSucceedWithConfig() {
        // Given
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = sut.storedComponents.first { $0.paymentMethod.type.rawValue == "twint" }

        // Then
        let storedTwintComponent = paymentComponent as? StoredPaymentMethodComponent
        XCTAssertNotNil(storedTwintComponent)
    }
    
    func test_componentManager_contains_payToComponent() {
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = sut.regularComponents.first { $0.paymentMethod.type.rawValue == "payto" }
        
        XCTAssertNotNil(paymentComponent)
    }
    
    func test_componentManager_contains_storedPayToComponent() {
        // Given
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = sut.storedComponents.first { $0.paymentMethod.type.rawValue == "payto" }

        // Then
        XCTAssertNotNil(paymentComponent as? StoredPaymentMethodComponent)
    }

    func testOrderInjection() {
        let order = PartialPaymentOrder(pspReference: "test pspRef", orderData: "test order data")

        var paymentMethods = paymentMethods
        paymentMethods.paid = [
            OrderPaymentMethod(
                lastFour: "1234",
                type: .other("type-1"),
                transactionLimit: Amount(value: 123, currencyCode: "EUR"),
                amount: Amount(value: 1234, currencyCode: "EUR")
            ),
            OrderPaymentMethod(
                lastFour: "1234",
                type: .other("type-2"),
                transactionLimit: Amount(value: 123, currencyCode: "EUR"),
                amount: Amount(value: 1234, currencyCode: "EUR")
            )
        ]

        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: order,
            presentationDelegate: presentationDelegate
        )

        // Paid section should contain the paid payment methods
        let paidSection = sut.sections.first { $0.paymentMethods.contains { $0 is OrderPaymentMethod } }
        XCTAssertNotNil(paidSection)
        XCTAssertEqual(paidSection?.paymentMethods.count, 2)

        XCTAssertEqual(sut.storedComponents.count, numberOfExpectedStoredComponent)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.storedComponents.filter { $0.order == order }.count, numberOfExpectedStoredComponent)
        XCTAssertEqual(sut.regularComponents.filter { $0.order == order }.count, numberOfExpectedRegularComponents)
    }

}

private final class DropInLocalizationProviderMock: CheckoutLocalizationProvider {
    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        nil
    }
}
