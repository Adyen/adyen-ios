//
//  SessionTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 3/8/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

@testable import AdyenSession
import XCTest
@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import AdyenComponents
import AdyenDropIn

class SessionTests: XCTestCase {

    var analyticsProviderMock: AnalyticsProviderMock!
    var context: AdyenContext!

    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsProviderMock = AnalyticsProviderMock()
        analyticsProviderMock.underlyingCheckoutAttemptId = "d06da733-ec41-4739-a532-5e8deab1262e16547639430681e1b021221a98c4bf13f7366b30fec4b376cc8450067ff98998682dd24fc9bda"
        context = Dummy.context(with: analyticsProviderMock)
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
        try super.tearDownWithError()
    }

    func testInitialization() throws {
        let apiClient = APIClientMock()
        let dictionary = [
            "storedPaymentMethods": [
                storedCreditCardDictionary,
                storedCreditCardDictionary,
                storedPayPalDictionary,
                storedBcmcDictionary
            ],
            "paymentMethods": [
                creditCardDictionary,
                issuerListDictionary
            ]
        ]
        let expectedPaymentMethods = try Coder.decode(dictionary) as PaymentMethods
        apiClient.mockedResults = [.success(SessionSetupResponse(countryCode: "US",
                                                                 shopperLocale: "US",
                                                                 paymentMethods: expectedPaymentMethods,
                                                                 amount: .init(value: 220, currencyCode: "USD"),
                                                                 sessionData: "session_data_1",
                                                                 configuration: .init(installmentOptions: nil, enableStoreDetails: false)))]
        let expectation = expectation(description: "Expect session object to be initialized")
        AdyenSession.initialize(with: .init(sessionIdentifier: "session_id",
                                            initialSessionData: "session_data_0",
                                            context: context),
                                delegate: SessionDelegateMock(),
                                presentationDelegate: PresentationDelegateMock(),
                                baseAPIClient: apiClient) { result in
            switch result {
            case .failure:
                XCTFail()
            case let .success(session):
                XCTAssertEqual(session.sessionContext.identifier, "session_id")
                XCTAssertEqual(session.sessionContext.data, "session_data_1")
                XCTAssertEqual(session.sessionContext.shopperLocale, "US")
                XCTAssertEqual(session.sessionContext.countryCode, "US")
                XCTAssertEqual(session.sessionContext.paymentMethods, expectedPaymentMethods)
                XCTAssertEqual(session.sessionContext.amount, .init(value: 220, currencyCode: "USD"))
                XCTAssertFalse(session.sessionContext.configuration.enableStoreDetails)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidSubmitWithNoActionAndNoOrder() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: nil,
            order: nil
        )
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       context: context)
        let apiClient = APIClientMock()
        sut.apiClient = apiClient
        apiClient.mockedResults = [.success(PaymentsResponse(resultCode: .authorised,
                                                             action: nil,
                                                             order: nil,
                                                             sessionData: "session_data"))]
        let didSubmitExpectation = expectation(description: "Expect payments call to be made")
        apiClient.onExecute = {
            didSubmitExpectation.fulfill()
        }
        sut.didSubmit(data, from: component)
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testDidSubmitWithCheckoutAttemptIdNonNilShouldIncludeCheckoutAttemptIdInPaymentComponentData() throws {
        // Given
        let expectedCheckoutAttemptId = try XCTUnwrap(analyticsProviderMock.underlyingCheckoutAttemptId)

        let sessionAdvancedHandlerMock = SessionAdvancedHandlerMock()
        let sessionDelegateMock = SessionDelegateMock()
        sessionDelegateMock.handlerMock = sessionAdvancedHandlerMock

        let paymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: paymentMethods, delegate: sessionDelegateMock)

        let paymentMethod = try XCTUnwrap(paymentMethods.regular.last as? MBWayPaymentMethod)
        let component = MBWayComponent(paymentMethod: paymentMethod, context: context)
        component.delegate = sut

        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        // When
        XCTAssertNil(paymentComponentData.checkoutAttemptId)
        component.submit(data: paymentComponentData, component: component)

        sessionAdvancedHandlerMock.onDidSubmit = { data, _, _ in
            // Then
            XCTAssertEqual(expectedCheckoutAttemptId, data.checkoutAttemptId)
        }
    }

    func testDidSubmitWithCheckoutAttemptIdNilShouldNotIncludeCheckoutAttemptIdInPaymentComponentData() throws {
        // Given
        analyticsProviderMock.underlyingCheckoutAttemptId = nil

        let sessionAdvancedHandlerMock = SessionAdvancedHandlerMock()
        let sessionDelegateMock = SessionDelegateMock()
        sessionDelegateMock.handlerMock = sessionAdvancedHandlerMock

        let paymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: paymentMethods, delegate: sessionDelegateMock)

        let paymentMethod = try XCTUnwrap(paymentMethods.regular.last as? MBWayPaymentMethod)
        let component = MBWayComponent(paymentMethod: paymentMethod, context: context)
        component.delegate = sut

        let paymentMethodDetails = MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "0284294824")
        let paymentComponentData = PaymentComponentData(paymentMethodDetails: paymentMethodDetails, amount: nil, order: nil)

        // When
        XCTAssertNil(paymentComponentData.checkoutAttemptId)
        component.submit(data: paymentComponentData, component: component)

        sessionAdvancedHandlerMock.onDidSubmit = { data, _, _ in
            // Then
            XCTAssertNil(data.checkoutAttemptId)
        }
    }
    
    private let paymentMethodsDictionary = [
        "storedPaymentMethods": [
            storedCreditCardDictionary,
            storedCreditCardDictionary,
            storedPayPalDictionary,
            storedBcmcDictionary
        ],
        "paymentMethods": [
            giftCard,
            creditCardDictionary,
            issuerListDictionary,
            mbway
        ]
    ]
    
    func testDidSubmitWithActionAndNoOrder() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: nil,
            order: nil
        )
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       context: context)
        let apiClient = APIClientMock()
        sut.apiClient = apiClient
        let expectedAction = RedirectAction(
            url: URL(string: "https://google.com")!,
            paymentData: "payment_data"
        )
        apiClient.mockedResults = [
            .success(
                PaymentsResponse(
                    resultCode: .authorised,
                    action: .redirect(
                        expectedAction
                    ),
                    order: nil,
                    sessionData: "session_data"
                )
            ),
            .success(
                PaymentsResponse(
                    resultCode: .authorised,
                    action: nil,
                    order: nil,
                    sessionData: "session_data"
                )
            )
        ]
        let didSubmitExpectation = expectation(description: "Expect payments and payments details calls to be made")
        didSubmitExpectation.expectedFulfillmentCount = 2
        apiClient.onExecute = {
            didSubmitExpectation.fulfill()
        }
        
        let actionExpectation = expectation(description: "Expect action to be handled")
        let actionComponent = ActionHandlingComponentMock()
        actionComponent.onAction = { action in
            switch action {
            case let .redirect(redirect):
                XCTAssertEqual(redirect.paymentData, expectedAction.paymentData)
                XCTAssertEqual(redirect.url, expectedAction.url)
                let data = ActionComponentData(
                    details: try! RedirectDetails(
                        returnURL: Dummy.returnUrl
                    ),
                    paymentData: "payment_data"
                )
                sut.didProvide(data, from: RedirectComponent(context: self.context))
            default:
                XCTFail()
            }
            actionExpectation.fulfill()
        }
        sut.actionComponent = actionComponent
        sut.didSubmit(data, from: component)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidSubmitWithOrderAndNoAction() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: nil,
            order: nil
        )
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       context: context)
        let dropInComponent = DropInComponent(paymentMethods: expectedPaymentMethods,
                                              context: Dummy.context,
                                              title: nil)
        let apiClient = APIClientMock()
        sut.apiClient = apiClient
        let expectedOrder = PartialPaymentOrder(pspReference: "pspReference",
                                                orderData: "order_data",
                                                reference: "reference",
                                                amount: .init(
                                                    value: 220,
                                                    currencyCode: "USD",
                                                    localeIdentifier: nil
                                                ),
                                                remainingAmount: .init(
                                                    value: 20,
                                                    currencyCode: "USD",
                                                    localeIdentifier: nil
                                                ),
                                                expiresAt: Date())
        let expectedAmount = Amount(
            value: 440,
            currencyCode: "EGP",
            localeIdentifier: nil
        )
        apiClient.mockedResults = [
            .success(
                PaymentsResponse(
                    resultCode: .authorised,
                    action: nil,
                    order: expectedOrder,
                    sessionData: "session_data"
                )
            ),
            .success(
                SessionSetupResponse(countryCode: "EG",
                                     shopperLocale: "EG",
                                     paymentMethods: expectedPaymentMethods,
                                     amount: expectedAmount,
                                     sessionData: "session_data_xxx",
                                     configuration: .init(installmentOptions: nil, enableStoreDetails: true))
            )
        ]
        let apiCallsExpectation = expectation(description: "Expect two API calls to be made")
        apiCallsExpectation.expectedFulfillmentCount = 2
        apiClient.onExecute = {
            apiCallsExpectation.fulfill()
        }
        sut.didSubmit(data, from: component, in: dropInComponent)
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssertEqual(sut.sessionContext.amount, expectedAmount)
        XCTAssertEqual(sut.sessionContext.countryCode, "EG")
        XCTAssertEqual(sut.sessionContext.shopperLocale, "EG")
        XCTAssertEqual(sut.sessionContext.data, "session_data_xxx")
        XCTAssertNil(sut.sessionContext.configuration.installmentOptions)
        XCTAssertTrue(sut.sessionContext.configuration.enableStoreDetails)
    }
    
    func testDidSubmitFailure() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: .init(
                value: 20,
                currencyCode: "USD",
                localeIdentifier: nil
            ),
            order: nil
        )
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       context: context)
        let apiClient = APIClientMock()
        sut.apiClient = apiClient
        
        apiClient.mockedResults = [.failure(Dummy.error)]
        let didSubmitExpectation = expectation(description: "Expect payments call to be made")
        apiClient.onExecute = {
            didSubmitExpectation.fulfill()
        }
        sut.didSubmit(data, from: component)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidSubmitOrderRefused() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        
        let dropInComponent = DropInComponent(paymentMethods: expectedPaymentMethods,
                                              context: context,
                                              title: nil)
        
        UIApplication.shared.keyWindow?.rootViewController = dropInComponent.viewController

        wait(for: .milliseconds(300))
        
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: .init(
                value: 20,
                currencyCode: "USD",
                localeIdentifier: nil
            ),
            order: nil
        )
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       context: context)
        let apiClient = APIClientMock()
        sut.apiClient = apiClient
        
        let expectedOrder = PartialPaymentOrder(pspReference: "pspReference",
                                                orderData: "order_data",
                                                reference: "reference",
                                                amount: .init(
                                                    value: 220,
                                                    currencyCode: "USD",
                                                    localeIdentifier: nil
                                                ),
                                                remainingAmount: .init(
                                                    value: 20,
                                                    currencyCode: "USD",
                                                    localeIdentifier: nil
                                                ),
                                                expiresAt: Date())
        
        let expectedAmount = Amount(
            value: 440,
            currencyCode: "EGP",
            localeIdentifier: nil
        )
        
        apiClient.mockedResults = [
            .success(
                PaymentsResponse(
                    resultCode: .refused,
                    action: nil,
                    order: expectedOrder,
                    sessionData: "session_data"
                )
            ),
            .success(
                SessionSetupResponse(countryCode: "EG",
                                     shopperLocale: "EG",
                                     paymentMethods: expectedPaymentMethods,
                                     amount: expectedAmount,
                                     sessionData: "session_data_xxx",
                                     configuration: .init(installmentOptions: nil, enableStoreDetails: true))
            )
        ]
        let didSubmitExpectation = expectation(description: "Expect payments call to be made")
        apiClient.onExecute = {
            didSubmitExpectation.fulfill()
        }
        
        sut.didSubmit(data, from: component, in: dropInComponent)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testCheckBalanceCheckSuccess() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        let paymentData = PaymentComponentData(paymentMethodDetails: details, amount: nil, order: nil)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(BalanceCheckResponse(sessionData: "session_data2",
                                                                 balance: Amount(value: 50, currencyCode: "EUR"),
                                                                 transactionLimit: Amount(value: 30, currencyCode: "EUR")))]
        
        let expectation = expectation(description: "Expect API call to be made")
        apiClient.onExecute = {
            expectation.fulfill()
        }
        sut.checkBalance(with: paymentData, component: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            let balance = try! result.get()
            XCTAssertEqual(balance.availableAmount.value, 50)
            XCTAssertEqual(balance.transactionLimit!.value, 30)
            XCTAssertEqual(sut.sessionContext.data, "session_data2")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testBalanceCheckZeroBalance() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        let paymentData = PaymentComponentData(paymentMethodDetails: details, amount: nil, order: nil)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(BalanceCheckResponse(sessionData: "session_data2",
                                                                 balance: nil,
                                                                 transactionLimit: nil))]
        
        let expectation = expectation(description: "Expect API call to be made")
        apiClient.onExecute = {
            expectation.fulfill()
        }
        // get .failure
        sut.checkBalance(with: paymentData, component: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            XCTAssertNotNil(result.failure)
            XCTAssertEqual(sut.sessionContext.data, "session_data2")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testBalanceCheckFailure() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        let paymentData = PaymentComponentData(paymentMethodDetails: details, amount: nil, order: nil)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.failure(BalanceChecker.Error.zeroBalance)]
        
        let expectation = expectation(description: "Expect API call to be made")
        apiClient.onExecute = {
            expectation.fulfill()
        }
        // get .failure
        sut.checkBalance(with: paymentData, component: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            XCTAssertNotNil(result.failure)
            XCTAssertEqual(sut.sessionContext.data, "session_data_1")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRequestOrderSuccess() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        
        apiClient.mockedResults = [.success(CreateOrderResponse(pspReference: "ref",
                                                                orderData: "data",
                                                                sessionData: "session_data2"))]
        
        let expectation = expectation(description: "Expect API call to be made")
        apiClient.onExecute = {
            expectation.fulfill()
        }
        sut.requestOrder(for: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            let order = try! result.get()
            XCTAssertEqual(order.pspReference, "ref")
            XCTAssertEqual(order.orderData, "data")
            XCTAssertEqual(sut.sessionContext.data, "session_data2")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRequestOrderFailure() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        
        apiClient.mockedResults = [.failure(PartialPaymentError.missingOrderData)]
        
        let expectation = expectation(description: "Expect API call to be made")
        apiClient.onExecute = {
            expectation.fulfill()
        }
        sut.requestOrder(for: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            XCTAssertNotNil(result.failure)
            XCTAssertEqual(sut.sessionContext.data, "session_data_1")
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testCancelOrderSuccess() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        
        apiClient.mockedResults = [.success(CancelOrderResponse(sessionData: "session_data2"))]
        
        let order = PartialPaymentOrder(pspReference: "ref", orderData: nil)
        sut.cancelOrder(order, component: PaymentComponentMock(paymentMethod: paymentMethod))
        
        wait(for: .seconds(1))
        XCTAssertEqual(sut.sessionContext.data, "session_data2")
    }
    
    func testCancelOrderFailure() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        
        apiClient.mockedResults = [.failure(PartialPaymentError.missingOrderData)]
        
        let order = PartialPaymentOrder(pspReference: "ref", orderData: nil)
        sut.cancelOrder(order, component: PaymentComponentMock(paymentMethod: paymentMethod))
        
        wait(for: .seconds(1))
        XCTAssertEqual(sut.sessionContext.data, "session_data_1")
    }
    
    func testDelegateDidSubmitHandler() throws {
        let sessionHandlerMock = SessionAdvancedHandlerMock()
        let sessionDelegate = SessionDelegateMock()
        sessionDelegate.handlerMock = sessionHandlerMock
        
        let didSubmitExpectation = expectation(description: "handler didSubmit should be called")
        sessionHandlerMock.onDidSubmit = { data, component, session in
            didSubmitExpectation.fulfill()
        }
        
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods,
                                        delegate: sessionDelegate)
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: nil,
            order: nil
        )
        let component = MBWayComponent(paymentMethod: paymentMethod,
                                       context: context)
        sut.didSubmit(data, from: component)
        wait(for: [didSubmitExpectation], timeout: 2)
    }
    
    func testDelegateDidProvideHandler() throws {
        let sessionHandlerMock = SessionAdvancedHandlerMock()
        let sessionDelegate = SessionDelegateMock()
        sessionDelegate.handlerMock = sessionHandlerMock
        
        let didProvideExpectation = expectation(description: "handler didProvide should be called")
        sessionHandlerMock.onDidProvide = { data, component, session in
            didProvideExpectation.fulfill()
        }
        
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        let data = ActionComponentData(
            details: try RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(data, from: RedirectComponent(context: context))
        wait(for: [didProvideExpectation], timeout: 2)
    }
    
    func testSessionAsDropInDelegate() throws {
        let config = DropInComponent.Configuration()

        let paymenMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        let dropIn = DropInComponent(paymentMethods: paymenMethods,
                                     context: context,
                                     configuration: config)
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionHandlerMock = SessionAdvancedHandlerMock()
        let sessionDelegate = SessionDelegateMock()
        sessionDelegate.handlerMock = sessionHandlerMock
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        dropIn.delegate = sut
        
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        let paymentComponent = PaymentComponentMock(paymentMethod: paymentMethod)
        let actionComponent = QRCodeActionComponent(context: context)
        
        let didFailExpectation = expectation(description: "didFail should be called")
        sessionDelegate.onDidFail = { error, component, session in
            XCTAssertTrue(error is ComponentError)
            XCTAssertTrue(session === sut)
            didFailExpectation.fulfill()
        }
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, component, session in
            XCTAssertTrue(session === sut)
            didCompleteExpectation.fulfill()
        }
        
        let didOpenExternalAppExpectation = expectation(description: "didOpenExternalApplication should be called")
        sessionDelegate.onDidOpenExternalApplication = {
            didOpenExternalAppExpectation.fulfill()
        }
        
        let didProvideExpectation = expectation(description: "handler didProvide should be called")
        sessionHandlerMock.onDidProvide = { data, component, session in
            XCTAssertTrue(component === actionComponent)
            XCTAssertTrue(session === sut)
            didProvideExpectation.fulfill()
        }
        
        let didSubmitExpectation = expectation(description: "handler didSubmit should be called")
        sessionHandlerMock.onDidSubmit = { data, component, session in
            XCTAssertTrue(component === paymentComponent)
            XCTAssertTrue(session === sut)
            didSubmitExpectation.fulfill()
        }
        
        let paymentData = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: nil,
            order: nil
        )
        
        let actionData = ActionComponentData(
            details: try RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        
        dropIn.didFail(with: ComponentError.paymentMethodNotSupported, from: paymentComponent)
        dropIn.didOpenExternalApplication(component: QRCodeActionComponent(context: context))
        dropIn.didSubmit(paymentData, from: paymentComponent)
        dropIn.didProvide(actionData, from: actionComponent)
        sut.sessionContext.resultCode = .authorised
        dropIn.didComplete(from: actionComponent)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testResultCodeAuthorised() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .authorised,
                action: nil,
                order: nil,
                sessionData: "session_data"
            )
        )]
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result, .authorised)
            didCompleteExpectation.fulfill()
        }
        let actionData = ActionComponentData(
            details: try RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 2)
    }
    
    func testResultCodePending() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .pending,
                action: nil,
                order: nil,
                sessionData: "session_data"
            )
        )]
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result, .pending)
            didCompleteExpectation.fulfill()
        }
        let actionData = ActionComponentData(
            details: try RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 2)
    }
    
    func testResultCodeRefused() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .refused,
                action: nil,
                order: nil,
                sessionData: "session_data"
            )
        )]
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result, .refused)
            didCompleteExpectation.fulfill()
        }
        let actionData = ActionComponentData(
            details: try RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 2)
    }
    
    func testResultCodeCancelled() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .cancelled,
                action: nil,
                order: nil,
                sessionData: "session_data"
            )
        )]
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result, .cancelled)
            didCompleteExpectation.fulfill()
        }
        let actionData = ActionComponentData(
            details: try RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 2)
    }
    
    func testResultCodeReceived() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .received,
                action: nil,
                order: nil,
                sessionData: "session_data"
            )
        )]
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result, .received)
            didCompleteExpectation.fulfill()
        }
        let actionData = ActionComponentData(
            details: try RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 2)
    }
    
    func testResultCodePresentToShopper() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .presentToShopper,
                action: nil,
                order: nil,
                sessionData: "session_data"
            )
        )]
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result, .presentToShopper)
            didCompleteExpectation.fulfill()
        }
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        let paymentComponent = PaymentComponentMock(paymentMethod: paymentMethod)
        let paymentData = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: nil,
            order: nil
        )
        sut.didSubmit(paymentData, from: paymentComponent)
        wait(for: [didCompleteExpectation], timeout: 2)
    }
    
    func testResultCodeError() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .error,
                action: nil,
                order: nil,
                sessionData: "session_data"
            )
        )]
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result, .error)
            didCompleteExpectation.fulfill()
        }
        let actionData = ActionComponentData(
            details: try RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 2)
    }
    
    func testResultCodeErrorFromAnotherCode() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
        let apiClient = APIClientMock()
        sut.apiClient = SessionAPIClient(apiClient: apiClient, session: sut)
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .redirectShopper,
                action: nil,
                order: nil,
                sessionData: "session_data"
            )
        )]
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result, .error)
            didCompleteExpectation.fulfill()
        }
        let actionData = ActionComponentData(
            details: try RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 2)
    }
    
    func testInstallmentsFromSessionConfig() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let config = try! JSONDecoder().decode(SessionSetupResponse.Configuration.self, from: sessionConfigJson.data(using: .utf8)!)
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, configuration: config)
        let paymentMethod = expectedPaymentMethods.regular[1] as! CardPaymentMethod
        var cardConfig = CardComponent.Configuration()
        cardConfig.installmentConfiguration = .init(cardBasedOptions: [.americanExpress: .init(maxInstallmentMonth: 5, includesRevolving: false)], defaultOptions: .init(monthValues: [3, 5], includesRevolving: true))
        let cardComponent = CardComponent(paymentMethod: paymentMethod, context: context)
        cardComponent.delegate = sut
        
        XCTAssertEqual(cardConfig.installmentConfiguration?.defaultOptions, .init(monthValues: [3, 5], includesRevolving: true))
        
        XCTAssertEqual(cardConfig.installmentConfiguration?.cardBasedOptions, [.americanExpress: .init(monthValues: [2, 3, 4, 5], includesRevolving: false)])
        
        // card component installments config should be overriden by session response
        XCTAssertEqual(cardComponent.configuration.installmentConfiguration?.cardBasedOptions, [.visa: .init(monthValues: [3, 6, 9], includesRevolving: true)])
        XCTAssertEqual(cardComponent.configuration.installmentConfiguration?.defaultOptions, .init(monthValues: [2, 3, 5], includesRevolving: false))
    }
    
    func testStorePaymentMethodFieldNotNil() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let config = try! JSONDecoder().decode(SessionSetupResponse.Configuration.self, from: sessionConfigJson.data(using: .utf8)!)
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, configuration: config)
        let paymentMethod = expectedPaymentMethods.regular[1] as! CardPaymentMethod
        var cardConfig = CardComponent.Configuration()
        cardConfig.showsStorePaymentMethodField = false // will be overriden as true by session response
        
        let cardComponent = CardComponent(paymentMethod: paymentMethod, context: context)
        cardComponent.delegate = sut
        
        UIApplication.shared.keyWindow?.rootViewController = cardComponent.viewController
        
        wait(for: .milliseconds(300))
        
        XCTAssertNotNil(cardComponent.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
        XCTAssertTrue(cardComponent.configuration.showsStorePaymentMethodField)
    }
    
    func testStorePaymentMethodFieldNil() throws {
        let expectedPaymentMethods = try Coder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = try initializeSession(expectedPaymentMethods: expectedPaymentMethods, configuration: .init(installmentOptions: nil, enableStoreDetails: false))
        let paymentMethod = expectedPaymentMethods.regular[1] as! CardPaymentMethod
        var cardConfig = CardComponent.Configuration()
        cardConfig.showsStorePaymentMethodField = true // will be overriden as false by session response
        
        let cardComponent = CardComponent(paymentMethod: paymentMethod, context: context)
        cardComponent.delegate = sut
        
        UIApplication.shared.keyWindow?.rootViewController = cardComponent.viewController
        
        wait(for: .milliseconds(300))
        
        XCTAssertNil(cardComponent.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
        XCTAssertFalse(cardComponent.configuration.showsStorePaymentMethodField)
    }
    
    private func initializeSession(expectedPaymentMethods: PaymentMethods,
                                   delegate: AdyenSessionDelegate = SessionDelegateMock(),
                                   configuration: SessionSetupResponse.Configuration = .init(installmentOptions: nil, enableStoreDetails: true)) throws -> AdyenSession {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(
                SessionSetupResponse(
                    countryCode: "US",
                    shopperLocale: "US",
                    paymentMethods: expectedPaymentMethods,
                    amount: .init(
                        value: 220,
                        currencyCode: "USD"
                    ),
                    sessionData: "session_data_1",
                    configuration: configuration
                )
            )
        ]
        var sut: AdyenSession!
        let initializationExpectation = expectation(description: "Expect session object to be initialized")
        AdyenSession.initialize(with: .init(sessionIdentifier: "session_id",
                                            initialSessionData: "session_data_0",
                                            context: context),
                                delegate: delegate,
                                presentationDelegate: PresentationDelegateMock(),
                                baseAPIClient: apiClient) { result in
            switch result {
            case let .success(session):
                sut = session
                initializationExpectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        wait(for: [initializationExpectation], timeout: 2)
        return sut
    }

}

extension PaymentMethods: Equatable {
    public static func == (lhs: PaymentMethods, rhs: PaymentMethods) -> Bool {
        guard lhs.regular.count == rhs.regular.count else { return false }
        guard lhs.stored.count == rhs.stored.count else { return false }
        for (paymentMethod1, paymentMethod2) in zip(lhs.regular, rhs.regular) {
            if paymentMethod1 != paymentMethod2 {
                return false
            }
        }
        for (paymentMethod1, paymentMethod2) in zip(lhs.stored, rhs.stored) {
            if paymentMethod1 != paymentMethod2 {
                return false
            }
        }
        return true
    }
}

let sessionConfigJson = """
{
    "installmentOptions": {
        "card": {
            "plans": [
                "regular"
            ],
            "values": [
                2,
                3,
                5
            ]
        },
        "visa": {
            "plans": [
                "regular", "revolving"
            ],
            "values": [
                3,
                6,
                9
            ]
        }
    },
    "enableStoreDetails": true
}
"""
