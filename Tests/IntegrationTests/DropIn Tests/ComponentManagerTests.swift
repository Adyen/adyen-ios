//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenComponents
@testable import AdyenDropIn
#if canImport(AdyenCashAppPay)
    @testable import AdyenCashAppPay
#endif

#if canImport(AdyenCashAppPay)
    @testable import AdyenTwint
#endif
import PassKit
import XCTest

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
            storedTwintDictionary
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
            boleto,
            affirm,
            atome,
            achDirectDebit,
            bacsDirectDebit,
            cashAppPay,
            giftCard,
            mealVoucherSodexo,
            twint
        ]
    ]
    
    let numberOfExpectedRegularComponents = 24

    var presentationDelegate: PresentationDelegateMock!
    var context: AdyenContext!
    var configuration: DropInComponent.Configuration!

    override func setUpWithError() throws {
        try super.setUpWithError()
        presentationDelegate = PresentationDelegateMock()
        context = Dummy.context
        configuration = DropInComponent.Configuration()
    }

    override func tearDownWithError() throws {
        AdyenAssertion.listener = nil
        presentationDelegate = nil
        context = nil
        configuration = nil
        try super.tearDownWithError()
    }

    func testClientKeyInjectionAndProtocolConformance() throws {
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        XCTAssertEqual(sut.storedComponents.count, 6)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.storedComponents.filter { $0.context.apiContext.clientKey == Dummy.apiContext.clientKey }.count, 6)
        XCTAssertEqual(sut.regularComponents.filter { $0.context.apiContext.clientKey == Dummy.apiContext.clientKey }.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.regularComponents.filter { $0 is LoadingComponent }.count, 19)
        XCTAssertEqual(sut.regularComponents.filter { $0 is PresentableComponent }.count, 19)
        XCTAssertEqual(sut.regularComponents.filter { $0 is FinalizableComponent }.count, 0)
    }

    func testApplePayPaymentMethod() {
        configuration.applePay = .init(payment: Dummy.createTestApplePayPayment(), merchantIdentifier: "merchant.com.test")
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        XCTAssertEqual(sut.storedComponents.count, 6)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents + 1)

        XCTAssertEqual(sut.regularComponents.filter { $0 is LoadingComponent }.count, 19)
        XCTAssertEqual(sut.regularComponents.filter { $0 is PresentableComponent }.count, 20)
        XCTAssertEqual(sut.regularComponents.filter { $0 is FinalizableComponent }.count, 1)
    }
    
    func testCashAppShouldFailWithoutConfig() {
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )
        
        let paymentComponent = sut.regularComponents.first { $0.paymentMethod.type.rawValue == "cashapp" }

        XCTAssertNil(paymentComponent)
    }
    
    func testCashAppShouldSucceedWithConfig() throws {
        configuration.cashAppPay = .init(redirectURL: URL(string: "test")!)
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )
        
        // When
        let paymentComponent = sut.regularComponents.first { $0.paymentMethod.type.rawValue == "cashapp" }

        // Then
        let cashAppPayComponent = paymentComponent as? CashAppPayComponent
        #if canImport(AdyenCashAppPay)
            XCTAssertNotNil(cashAppPayComponent)
        #else
            XCTAssertNil(cashAppPayComponent)
        #endif
    }

    func testTwintShouldSucceedWithConfig() throws {
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
            let twintComponent = paymentComponent as? InstantPaymentComponent
            XCTAssertNil(twintComponent)
        #endif
    }

    func testStoredTwintShouldSucceedWithConfig() throws {
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

    func testLocalizationWithCustomTableName() throws {
        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )
        
        XCTAssertEqual(sut.storedComponents.count, 6)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)
        
        XCTAssertEqual(sut.storedComponents.compactMap { ($0 as? StoredPaymentMethodComponent)?.configuration.localizationParameters }.filter { $0.tableName == "AdyenUIHost" }.count, 4)
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )
        
        XCTAssertEqual(sut.storedComponents.count, 6)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)
        
        XCTAssertEqual(sut.storedComponents.compactMap { ($0 as? StoredPaymentMethodComponent)?.configuration.localizationParameters }.filter { $0.keySeparator == "_" }.count, 4)
    }

    func testOrderInjection() throws {
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

        XCTAssertEqual(sut.paidComponents.count, 2)
        XCTAssertEqual(sut.storedComponents.count, 6)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.paidComponents.filter { $0.order == order }.count, 2)
        XCTAssertEqual(sut.storedComponents.filter { $0.order == order }.count, 6)
        XCTAssertEqual(sut.regularComponents.filter { $0.order == order }.count, numberOfExpectedRegularComponents)
    }

    func testOrderInjectionOnApplePay() throws {
        let payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        configuration.applePay = try .init(payment: .init(payment: payment, brand: "TEST"), merchantIdentifier: "test_test")

        let order = PartialPaymentOrder(
            pspReference: "test pspRef",
            orderData: "test order data",
            remainingAmount: Amount(value: 123456, currencyCode: "EUR")
        )

        var paymentMethods = paymentMethods
        paymentMethods.paid = [OrderPaymentMethod(
            lastFour: "1234",
            type: .other("type-1"),
            transactionLimit: Amount(value: 123, currencyCode: "EUR"),
            amount: Amount(value: 1234, currencyCode: "EUR")
        )]

        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: order,
            presentationDelegate: presentationDelegate
        )

        // Test Pre-ApplePay
        let preApplepayComponent = (sut.regularComponents.first(where: { $0.paymentMethod.type == .applePay }) as! PreApplePayComponent)
        XCTAssertEqual(preApplepayComponent.amount, order.remainingAmount)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnAffirmComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "affirm" })

        // Then
        let affirmComponent = try XCTUnwrap(paymentComponent as? AffirmComponent)
        XCTAssertNotNil(affirmComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnDokuComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "doku_wallet" })

        // Then
        let dokuComponent = try XCTUnwrap(paymentComponent as? DokuComponent)
        XCTAssertNotNil(dokuComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnMBWayComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "mbway" })

        // Then
        let mbwayComponent = try XCTUnwrap(paymentComponent as? MBWayComponent)
        XCTAssertNotNil(mbwayComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnBasicPersonalInfoFormComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "econtext_online" })

        // Then
        let basicPersonalInfoFormComponent = try XCTUnwrap(paymentComponent as? BasicPersonalInfoFormComponent)
        XCTAssertNotNil(basicPersonalInfoFormComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnBoletoComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "boletobancario_santander" })

        // Then
        let boletoComponent = try XCTUnwrap(paymentComponent as? BoletoComponent)
        XCTAssertNotNil(boletoComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnCardComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "scheme" })

        // Then
        let cardComponent = try XCTUnwrap(paymentComponent as? CardComponent)
        XCTAssertNotNil(cardComponent.configuration.shopperInformation)
    }
    
    func testShopperInformationInjectionShouldSetShopperInformationOnAtomeComponent() throws {
        // Given

        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // Action
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "atome" })

        // Assert
        let atomeComponent = try XCTUnwrap(paymentComponent as? AtomeComponent)
        XCTAssertNotNil(atomeComponent.configuration.shopperInformation)
    }

    func testBoletoConfiguration() throws {
        // Given
        configuration.boleto.showEmailAddress = false
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type == .boleto })

        // Then
        let boletoComponent = try XCTUnwrap(paymentComponent as? BoletoComponent)
        XCTAssertFalse(boletoComponent.configuration.showEmailAddress)
    }
    
    func testGiftCardConfiguration() throws {
        // Given
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type == .giftcard })

        // Then
        let giftCardComponent = try XCTUnwrap(paymentComponent as? GiftCardComponent)
        XCTAssertTrue(giftCardComponent.showsSecurityCodeField)
        XCTAssertTrue(giftCardComponent.requiresModalPresentation)
        XCTAssertEqual(giftCardComponent.localizationParameters, configuration.localizationParameters)
    }
    
    func testGiftCardSecurityCodeHiddenConfiguration() throws {
        // Given
        configuration.giftCard.showsSecurityCodeField = false
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type == .giftcard })

        // Then
        let giftCardComponent = try XCTUnwrap(paymentComponent as? GiftCardComponent)
        XCTAssertFalse(giftCardComponent.showsSecurityCodeField)
    }
    
    func testMealVoucherConfiguration() throws {
        // Given
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type == .mealVoucherSodexo })

        // Then
        let giftCardComponent = try XCTUnwrap(paymentComponent as? GiftCardComponent)
        XCTAssertTrue(giftCardComponent.showsSecurityCodeField)
        XCTAssertTrue(giftCardComponent.requiresModalPresentation)
        XCTAssertEqual(giftCardComponent.localizationParameters, configuration.localizationParameters)
    }
    
    func testMealVoucherSecurityCodeHiddenConfiguration() throws {
        // Given
        configuration.giftCard.showsSecurityCodeField = false
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type == .mealVoucherSodexo })

        // Then
        let giftCardComponent = try XCTUnwrap(paymentComponent as? GiftCardComponent)
        XCTAssertFalse(giftCardComponent.showsSecurityCodeField)
    }
    
    func testACHConfiguration() throws {
        // Given
        configuration.ach.showsStorePaymentMethodField = false
        configuration.ach.showsBillingAddress = false
        configuration.ach.billingAddressCountryCodes = ["US", "UK"]
        
        let sut = ComponentManager(
            paymentMethods: paymentMethods,
            context: context,
            configuration: configuration,
            order: nil,
            presentationDelegate: presentationDelegate
        )

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type == .achDirectDebit })

        // Then
        let achComponent = try XCTUnwrap(paymentComponent as? ACHDirectDebitComponent)
        XCTAssertFalse(achComponent.configuration.showsStorePaymentMethodField)
        XCTAssertFalse(achComponent.configuration.showsBillingAddress)
        XCTAssertEqual(achComponent.configuration.billingAddressCountryCodes, ["US", "UK"])
    }
    
    func testMissingImplementationBuildComponent() throws {
        
        struct DummyPaymentMethod: PaymentMethod {
            var type: PaymentMethodType = .achDirectDebit
            var name: String = ""
            var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation? = nil
            
            init() {}
            init(from decoder: Decoder) throws {}
            
            enum CodingKeys: CodingKey {} // Satisfying Encoding requirement
        }
        
        let dummy = DummyPaymentMethod()
        
        let expectation = expectation(description: "Access expectation")
        expectation.expectedFulfillmentCount = 1
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "`@_spi(AdyenInternal) buildComponent(using:)` needs to be implemented on `DummyPaymentMethod`")
            expectation.fulfill()
        }
        
        let componentManager = ComponentManager(
            paymentMethods: .init(regular: [], stored: []),
            context: Dummy.context,
            configuration: .init(),
            order: nil,
            presentationDelegate: presentationDelegate
        )

        let _ = dummy.buildComponent(using: componentManager)
        
        wait(for: [expectation], timeout: 10)
    }

    // MARK: - Private

    private var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let deliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        return .init(
            shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
            emailAddress: "katrina@mail.com",
            phoneNumber: .init(value: "1234567890", callingCode: "+1"),
            billingAddress: billingAddress,
            deliveryAddress: deliveryAddress,
            socialSecurityNumber: "78542134370"
        )
    }

}
