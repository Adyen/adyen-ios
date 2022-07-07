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
        return try! Coder.decode(dictionary) as PaymentMethods
    }
    
    let dictionary = [
        "storedPaymentMethods": [
            storedCreditCardDictionary,
            storedCreditCardDictionary,
            storedPayPalDictionary,
            storedBcmcDictionary
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
            atome
        ]
    ]
    
    let numberOfExpectedRegularComponents = 19

    var presentationDelegate: PresentationDelegateMock!
    var context: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        presentationDelegate = PresentationDelegateMock()
        context = Dummy.context
    }

    override func tearDownWithError() throws {
        presentationDelegate = nil
        context = nil
        try super.tearDownWithError()
    }

    func testClientKeyInjectionAndProtocolConfromance() throws {
        let config = DropInComponent.Configuration(context: context)
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: config,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.storedComponents.filter { $0.context.apiContext.clientKey == Dummy.apiContext.clientKey }.count, 4)
        XCTAssertEqual(sut.regularComponents.filter { $0.context.apiContext.clientKey == Dummy.apiContext.clientKey }.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.regularComponents.filter { $0 is LoadingComponent }.count, 15)
        XCTAssertEqual(sut.regularComponents.filter { $0 is PresentableComponent }.count, 15)
        XCTAssertEqual(sut.regularComponents.filter { $0 is FinalizableComponent }.count, 0)
    }

    func testApplePayPaymentMethod() {
        let config = DropInComponent.Configuration(context: context)
        config.applePay = .init(payment: Dummy.createTestApplePayPayment(), merchantIdentifier: "merchant.com.test")
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: config,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents + 1)

        XCTAssertEqual(sut.regularComponents.filter { $0 is LoadingComponent }.count, 15)
        XCTAssertEqual(sut.regularComponents.filter { $0 is PresentableComponent }.count, 16)
        XCTAssertEqual(sut.regularComponents.filter { $0 is FinalizableComponent }.count, 1)
    }
    
    func testLocalizationWithCustomTableName() throws {
        let config = DropInComponent.Configuration(context: context)
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: config,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)
        
        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)
        
        XCTAssertEqual(sut.storedComponents.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 2)
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let config = DropInComponent.Configuration(context: Dummy.context)
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   context: context,
                                   configuration: config,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)
        
        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)
        
        XCTAssertEqual(sut.storedComponents.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 2)
    }

    func testOrderInjection() throws {
        let config = DropInComponent.Configuration(context: Dummy.context)
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")

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
                                   configuration: config,
                                   order: order,
                                   presentationDelegate: presentationDelegate)

        XCTAssertEqual(sut.paidComponents.count, 2)
        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.paidComponents.filter { $0.order == order }.count, 2)
        XCTAssertEqual(sut.storedComponents.filter { $0.order == order }.count, 4)
        XCTAssertEqual(sut.regularComponents.filter { $0.order == order }.count, numberOfExpectedRegularComponents)
    }

    func testOrderInjectionOnApplePay() throws {
        let config = DropInComponent.Configuration(context: Dummy.context)
        let payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        config.payment = payment
        config.applePay = .init(payment: try .init(payment: payment, brand: "TEST"), merchantIdentifier: "test_test")

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
                                   configuration: config,
                                   order: order,
                                   presentationDelegate: presentationDelegate)

        // Test Pre-ApplePay
        let preApplepayComponent = (sut.regularComponents.first(where: { $0.paymentMethod.type == .applePay }) as! PreApplePayComponent)
        XCTAssertEqual(preApplepayComponent.amount, order.remainingAmount)
    }

    func testShopperInformationInjectionShouldSetShopperInformationOnAffirmComponent() throws {
        // Given
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let configuration = DropInComponent.Configuration(context: Dummy.context)
        configuration.shopper = shopperInformation
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
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let configuration = DropInComponent.Configuration(context: Dummy.context)
        configuration.shopper = shopperInformation
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
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let configuration = DropInComponent.Configuration(context: Dummy.context)
        configuration.shopper = shopperInformation
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
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let configuration = DropInComponent.Configuration(context: Dummy.context)
        configuration.shopper = shopperInformation
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
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let configuration = DropInComponent.Configuration(context: Dummy.context)
        configuration.shopper = shopperInformation
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
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let configuration = DropInComponent.Configuration(context: Dummy.context)
        configuration.shopper = shopperInformation
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
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let configuration = DropInComponent.Configuration(context: context)
        configuration.shopper = shopperInformation
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
