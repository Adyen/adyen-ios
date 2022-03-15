//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
@testable import AdyenDropIn
import PassKit
import XCTest

class ComponentManagerTests: XCTestCase {
    
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

    override func setUpWithError() throws {
        try super.setUpWithError()
        presentationDelegate = PresentationDelegateMock()
    }

    override func tearDownWithError() throws {
        presentationDelegate = nil
        try super.tearDownWithError()
    }

    func testClientKeyInjectionAndProtocolConfromance() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)

        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.storedComponents.filter { $0.apiContext.clientKey == Dummy.context.clientKey }.count, 4)
        XCTAssertEqual(sut.regularComponents.filter { $0.apiContext.clientKey == Dummy.context.clientKey }.count, numberOfExpectedRegularComponents)

        XCTAssertEqual(sut.regularComponents.filter { $0 is LoadingComponent }.count, 14)
        XCTAssertEqual(sut.regularComponents.filter { $0 is PresentableComponent }.count, 15)
    }
    
    func testLocalizationWithCustomTableName() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)
        
        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)
        
        XCTAssertEqual(sut.storedComponents.compactMap { $0 as? Localizable }.filter { $0.localizationParameters?.tableName == "AdyenUIHost" }.count, 2)
    }
    
    func testLocalizationWithCustomKeySeparator() throws {
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let sut = ComponentManager(paymentMethods: paymentMethods,
                                   configuration: config,
                                   order: nil,
                                   presentationDelegate: presentationDelegate)
        
        XCTAssertEqual(sut.storedComponents.count, 4)
        XCTAssertEqual(sut.regularComponents.count, numberOfExpectedRegularComponents)
        
        XCTAssertEqual(sut.storedComponents.compactMap { $0 as? Localizable }.filter { $0.localizationParameters == config.localizationParameters }.count, 2)
    }

    func testOrderInjection() throws {
        var paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let config = DropInComponent.Configuration(apiContext: Dummy.context)
        config.payment = Payment(amount: Amount(value: 20, currencyCode: "EUR"), countryCode: "NL")
        config.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let order = PartialPaymentOrder(pspReference: "test pspRef", orderData: "test order data")

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

    func testShopperInformationInjectionShouldSetShopperInformationOnAffirmComponent() throws {
        // Given
        let paymentMethods = try Coder.decode(dictionary) as PaymentMethods
        let configuration = DropInComponent.Configuration(apiContext: Dummy.context)
        configuration.shopper = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
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
        let configuration = DropInComponent.Configuration(apiContext: Dummy.context)
        configuration.shopper = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
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
        let configuration = DropInComponent.Configuration(apiContext: Dummy.context)
        configuration.shopper = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
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
        let configuration = DropInComponent.Configuration(apiContext: Dummy.context)
        configuration.shopper = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
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
        let configuration = DropInComponent.Configuration(apiContext: Dummy.context)
        configuration.shopper = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
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
        let configuration = DropInComponent.Configuration(apiContext: Dummy.context)
        configuration.shopper = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
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
        let configuration = DropInComponent.Configuration(apiContext: Dummy.context)
        configuration.shopper = shopperInformation
        let sut = ComponentManager(paymentMethods: paymentMethods,
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
