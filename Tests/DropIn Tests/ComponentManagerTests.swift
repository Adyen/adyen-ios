//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
@testable import AdyenDropIn
import PassKit
import XCTest

class ComponentManagerTests: XCTestCase {

    var paymentMethods: PaymentMethods {
        try! Coder.decode(dictionary) as PaymentMethods
    }
    
    let dictionary = [
        "storedPaymentMethods": [
            storedCreditCardDictionary,
            storedCreditCardDictionary,
            storedPayPalDictionary,
            storedBcmcDictionary,
            storedACHDictionary
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
            bacsDirectDebit
        ]
    ]
    
    let numberOfExpectedRegularComponents = 21

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
        presentationDelegate = nil
        context = nil
        configuration = nil
        try super.tearDownWithError()
    }

    func testClientKeyInjectionAndProtocolConfromance() throws {
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        XCTAssertEqual(sut.storedComponents.count, 5)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.storedComponents.filter { $0.context.apiContext.clientKey == Dummy.apiContext.clientKey }.count, 5)
        XCTAssertEqual(sut.regularComponents.filter { $0.context.apiContext.clientKey == Dummy.apiContext.clientKey }.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.regularComponents.filter { $0 is LoadingComponent }.count, 17)
        XCTAssertEqual(sut.regularComponents.filter { $0 is PresentableComponent }.count, 17)
        XCTAssertEqual(sut.regularComponents.filter { $0 is FinalizableComponent }.count, 0)
    }

    func testApplePayPaymentMethod() {
        configuration.applePay = .init(payment: Dummy.createTestApplePayPayment(), merchantIdentifier: "merchant.com.test")
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        XCTAssertEqual(sut.storedComponents.count, 5)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents + 1)

        XCTAssertEqual(sut.regularComponents.filter { $0 is LoadingComponent }.count, 17)
        XCTAssertEqual(sut.regularComponents.filter { $0 is PresentableComponent }.count, 18)
        XCTAssertEqual(sut.regularComponents.filter { $0 is FinalizableComponent }.count, 1)
    }
    
    func testLocalizationWithCustomTableName() throws {
        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)
        
        XCTAssertEqual(sut.storedComponents.count, 5)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)
        
        XCTAssertEqual(sut.storedComponents.compactMap { ($0 as? StoredPaymentMethodComponent)?.configuration.localizationParameters }.filter { $0.tableName == "AdyenUIHost" }.count, 3)
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)
        
        XCTAssertEqual(sut.storedComponents.count, 5)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)
        
        XCTAssertEqual(sut.storedComponents.compactMap { ($0 as? StoredPaymentMethodComponent)?.configuration.localizationParameters }.filter { $0.keySeparator == "_" }.count, 3)
    }

    func testOrderInjection() throws {
        let order = PartialPaymentOrder(pspReference: "test pspRef", orderData: "test order data")

        var paymentMethods = paymentMethods
        paymentMethods.paid = [
            OrderPaymentMethod(lastFour: "1234",
                               type: .other("type-1"),
                               transactionLimit: Amount(value: 123, currencyCode: "EUR"),
                               amount: Amount(value: 1234, currencyCode: "EUR")),
            OrderPaymentMethod(lastFour: "1234",
                               type: .other("type-2"),
                               transactionLimit: Amount(value: 123, currencyCode: "EUR"),
                               amount: Amount(value: 1234, currencyCode: "EUR"))
        ]

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: order,
                                   presentationDelegate: presentationDelegate)

        XCTAssertEqual(sut.paidComponents.count, 2)
        XCTAssertEqual(sut.storedComponents.count, 5)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.paidComponents.filter { $0.order == order }.count, 2)
        XCTAssertEqual(sut.storedComponents.filter { $0.order == order }.count, 5)
        XCTAssertEqual(sut.regularComponents.filter { $0.order == order }.count, numberOfExpectedRegularComponents)
    }

    func testOrderInjectionOnApplePay() throws {
        let payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        configuration.applePay = .init(payment: try .init(payment: payment, brand: "TEST"), merchantIdentifier: "test_test")

        let order = PartialPaymentOrder(pspReference: "test pspRef",
                                        orderData: "test order data",
                                        remainingAmount: Amount(value: 123456, currencyCode: "EUR"))

        var paymentMethods = paymentMethods
        paymentMethods.paid = [
            OrderPaymentMethod(lastFour: "1234",
                               type: .other("type-1"),
                               transactionLimit: Amount(value: 123, currencyCode: "EUR"),
                               amount: Amount(value: 1234, currencyCode: "EUR"))
        ]

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: order,
                                   presentationDelegate: presentationDelegate)

        // Test Pre-ApplePay
        let preApplepayComponent = (sut.regularComponents.first(where: { $0.paymentMethod.type == .applePay }) as! PreApplePayComponent)
        XCTAssertEqual(preApplepayComponent.amount, order.remainingAmount)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnAffirmComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "affirm" })

        // Then
        let affirmComponent = try XCTUnwrap(paymentComponent as? AffirmComponent)
        XCTAssertNotNil(affirmComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnDokuComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "doku_wallet" })

        // Then
        let dokuComponent = try XCTUnwrap(paymentComponent as? DokuComponent)
        XCTAssertNotNil(dokuComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnMBWayComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "mbway" })

        // Then
        let mbwayComponent = try XCTUnwrap(paymentComponent as? MBWayComponent)
        XCTAssertNotNil(mbwayComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnBasicPersonalInfoFormComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "econtext_online" })

        // Then
        let basicPersonalInfoFormComponent = try XCTUnwrap(paymentComponent as? BasicPersonalInfoFormComponent)
        XCTAssertNotNil(basicPersonalInfoFormComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnBoletoComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "boletobancario_santander" })

        // Then
        let boletoComponent = try XCTUnwrap(paymentComponent as? BoletoComponent)
        XCTAssertNotNil(boletoComponent.configuration.shopperInformation)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnCardComponent() throws {
        // Given
        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "scheme" })

        // Then
        let cardComponent = try XCTUnwrap(paymentComponent as? CardComponent)
        XCTAssertNotNil(cardComponent.configuration.shopperInformation)
    }
    
    func testShopperInformationInjectionShouldSetShopperInformationOnAtomeComponent() throws {
        // Given

        configuration.shopperInformation = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        // Action
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type.rawValue == "atome" })

        // Assert
        let atomeComponent = try XCTUnwrap(paymentComponent as? AtomeComponent)
        XCTAssertNotNil(atomeComponent.configuration.shopperInformation)
    }

    func testBoletoConfiguration() throws {
        // Given
        configuration.boleto.showEmailAddress = false
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: configuration,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        // When
        let paymentComponent = try XCTUnwrap(sut.regularComponents.first { $0.paymentMethod.type == .boleto })

        // Then
        let boletoComponent = try XCTUnwrap(paymentComponent as? BoletoComponent)
        XCTAssertFalse(boletoComponent.configuration.showEmailAddress)
    }

    // MARK: - Private

    private var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let deliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        let shopperInformation = PrefilledShopperInformation(shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
                                                             emailAddress: "katrina@mail.com",
                                                             telephoneNumber: "1234567890",
                                                             billingAddress: billingAddress,
                                                             deliveryAddress: deliveryAddress,
                                                             socialSecurityNumber: "78542134370")
        return shopperInformation
    }

}
