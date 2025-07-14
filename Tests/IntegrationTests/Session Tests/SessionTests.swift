//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import AdyenSession
@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import AdyenComponents
import AdyenDropIn

class SessionTests: XCTestCase {

    var analyticsProviderMock: AnalyticsProviderMock!
    var context: AdyenContext!

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsProviderMock = AnalyticsProviderMock()
        analyticsProviderMock._checkoutAttemptId = "d06da733-ec41-4739-a532-5e8deab1262e16547639430681e1b021221a98c4bf13f7366b30fec4b376cc8450067ff98998682dd24fc9bda"
        context = Dummy.context(with: analyticsProviderMock)
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
        try super.tearDownWithError()
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
        let expectedPaymentMethods = try AdyenCoder.decode(dictionary) as PaymentMethods
        apiClient.mockedResults = [.success(SessionSetupResponse(
            countryCode: "US",
            shopperLocale: "US",
            paymentMethods: expectedPaymentMethods,
            amount: .init(value: 220, currencyCode: "USD"),
            sessionData: "session_data_1",
            configuration: .init(installmentOptions: nil, enableStoreDetails: false)
        ))]
        let expectation = expectation(description: "Expect session object to be initialized")
        AdyenSession.setup(
            with: .init(
                sessionIdentifier: "session_id",
                initialSessionData: "session_data_0"
            ),
            apiClient: apiClient,
            actionHandlingComponent: ActionHandlingComponentMock(),
            delegate: SessionDelegateMock(),
            presentationDelegate: PresentationDelegateMock()
        ) { result in
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
                XCTAssertFalse(session.sessionContext.responseConfiguration.enableStoreDetails)
                XCTAssertFalse(session.sessionContext.responseConfiguration.showRemovePaymentMethodButton)
                XCTAssertEqual(AnalyticsForSession.sessionId, "session_id")
                XCTAssertTrue(session.isSession)
                XCTAssertEqual(session.showStorePaymentMethodField, session.sessionContext.responseConfiguration.enableStoreDetails)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidSubmitWithNoActionAndNoOrder() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: nil,
            order: nil
        )
        let component = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(PaymentsResponse(
            resultCode: .authorised,
            action: nil,
            order: nil,
            sessionData: "session_data",
            sessionResult: "sessionResultString"
        ))]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        
        let didSubmitExpectation = expectation(description: "Expect payments call to be made")
        apiClient.onExecute = { request in
            if request is PaymentsRequest {
                didSubmitExpectation.fulfill()
            }
        }
        sut.didSubmit(data, from: component)
        wait(for: [didSubmitExpectation], timeout: 1)
    }
    
    func testDidSubmitWithActionAndNoOrder() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: nil,
            order: nil
        )
        let component = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        let apiClient = APIClientMock()
        let expectedAction = RedirectAction(
            url: URL(string: "https://google.com")!,
            paymentData: "payment_data"
        )
        apiClient.mockedResults = [
            .success(
                PaymentsResponse(
                    resultCode: .authorised,
                    action: .redirect(expectedAction),
                    order: nil,
                    sessionData: "session_data",
                    sessionResult: "sessionResultString"
                )
            ),
            .success(
                PaymentsResponse(
                    resultCode: .authorised,
                    action: nil,
                    order: nil,
                    sessionData: "session_data",
                    sessionResult: "sessionResultString"
                )
            )
        ]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        let didSubmitExpectation = expectation(description: "Expect payments call to be made")
        let didProvideExpectation = expectation(description: "Expect payments details call to be made")
        apiClient.onExecute = { request in
            if request is PaymentsRequest {
                didSubmitExpectation.fulfill()
            }
            if request is PaymentDetailsRequest {
                didProvideExpectation.fulfill()
            }
        }
        
        let actionExpectation = expectation(description: "Expect action to be handled")
        let actionHandlingComponent = ActionHandlingComponentMock()
        actionHandlingComponent.onAction = { action in
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
        sut.actionHandlingComponent = actionHandlingComponent
        sut.didSubmit(data, from: component)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidSubmitWithOrderAndNoAction() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let paymentMethod = expectedPaymentMethods.regular.last as! MBWayPaymentMethod
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(
                paymentMethod: paymentMethod,
                telephoneNumber: "telephone"
            ),
            amount: nil,
            order: nil
        )
        let component = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        let dropInComponent = DropInComponent(
            paymentMethods: expectedPaymentMethods,
            context: context,
            title: nil
        )
        let apiClient = APIClientMock()
        let expectedOrder = PartialPaymentOrder(
            pspReference: "pspReference",
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
            expiresAt: Date()
        )
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
                    sessionData: "session_data",
                    sessionResult: "sessionResultString"
                )
            ),
            // session response after order to reload session
            .success(
                SessionSetupResponse(
                    countryCode: "EG",
                    shopperLocale: "EG",
                    paymentMethods: expectedPaymentMethods,
                    amount: expectedAmount,
                    sessionData: "session_data_xxx",
                    configuration: .init(installmentOptions: nil, enableStoreDetails: true, showRemovePaymentMethodButton: true)
                )
            )
        ]
        let apiCallsExpectation = expectation(description: "Expect two API calls to be made")
        apiCallsExpectation.expectedFulfillmentCount = 2
        apiClient.onExecute = { _ in
            apiCallsExpectation.fulfill()
        }
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        sut.didSubmit(data, from: component, in: dropInComponent)
        wait(for: [apiCallsExpectation], timeout: 1)
        
        XCTAssertEqual(sut.sessionContext.amount, expectedAmount)
        XCTAssertEqual(sut.sessionContext.countryCode, "EG")
        XCTAssertEqual(sut.sessionContext.shopperLocale, "EG")
        XCTAssertEqual(sut.sessionContext.data, "session_data_xxx")
        XCTAssertNil(sut.sessionContext.responseConfiguration.installmentOptions)
        XCTAssertTrue(sut.sessionContext.responseConfiguration.enableStoreDetails)
        XCTAssertTrue(sut.sessionContext.responseConfiguration.showRemovePaymentMethodButton)
    }
    
    func testDidSubmitFailure() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
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
        let component = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.failure(Dummy.error)]
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        
        let didSubmitExpectation = expectation(description: "Expect payments call to be made")
        apiClient.onExecute = { request in
            if request is PaymentsRequest {
                didSubmitExpectation.fulfill()
            }
        }
        sut.didSubmit(data, from: component)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDidSubmitOrderRefused() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        
        let dropInComponent = DropInComponent(
            paymentMethods: expectedPaymentMethods,
            context: context,
            title: nil
        )
        
        let viewController = dropInComponent.viewController
        viewController.loadViewIfNeeded()
        
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
        let component = MBWayComponent(
            paymentMethod: paymentMethod,
            context: context
        )
        let apiClient = APIClientMock()
        
        let expectedOrder = PartialPaymentOrder(
            pspReference: "pspReference",
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
            expiresAt: Date()
        )
        
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
                    sessionData: "session_data",
                    sessionResult: "sessionResultString"
                )
            ),
            .success(
                SessionSetupResponse(
                    countryCode: "EG",
                    shopperLocale: "EG",
                    paymentMethods: expectedPaymentMethods,
                    amount: expectedAmount,
                    sessionData: "session_data_xxx",
                    configuration: .init(installmentOptions: nil, enableStoreDetails: true)
                )
            )
        ]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        
        let didSubmitExpectation = expectation(description: "Expect payments call to be made")
        apiClient.onExecute = { request in
            if request is PaymentsRequest {
                didSubmitExpectation.fulfill()
            }
        }
        
        sut.didSubmit(data, from: component, in: dropInComponent)
        wait(for: [didSubmitExpectation], timeout: 1)
    }
    
    func testCheckBalanceCheckSuccess() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        let paymentData = PaymentComponentData(paymentMethodDetails: details, amount: nil, order: nil)
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(BalanceCheckResponse(
            sessionData: "session_data2",
            balance: Amount(value: 50, currencyCode: "EUR"),
            transactionLimit: Amount(value: 30, currencyCode: "EUR")
        ))]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        
        let expectation = expectation(description: "Expect check balance API call to be made")
        apiClient.onExecute = { request in
            if request is BalanceCheckRequest {
                expectation.fulfill()
            }
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
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        let paymentData = PaymentComponentData(paymentMethodDetails: details, amount: nil, order: nil)
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.success(BalanceCheckResponse(
            sessionData: "session_data2",
            balance: nil,
            transactionLimit: nil
        ))]
        
        let expectation = expectation(description: "Expect balance check API call to be made")
        apiClient.onExecute = { request in
            if request is BalanceCheckRequest {
                expectation.fulfill()
            }
        }
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        // get .failure
        sut.checkBalance(with: paymentData, component: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            XCTAssertNotNil(result.failure)
            XCTAssertEqual(sut.sessionContext.data, "session_data2")
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testBalanceCheckFailure() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        let paymentData = PaymentComponentData(paymentMethodDetails: details, amount: nil, order: nil)
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.failure(BalanceChecker.Error.zeroBalance)]
        
        let expectation = expectation(description: "Expect check balance API call to be made")
        apiClient.onExecute = { request in
            if request is BalanceCheckRequest {
                expectation.fulfill()
            }
        }
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        // get .failure
        sut.checkBalance(with: paymentData, component: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            XCTAssertNotNil(result.failure)
            XCTAssertEqual(sut.sessionContext.data, "session_data_0")
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testRequestOrderSuccess() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let apiClient = APIClientMock()
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        
        apiClient.mockedResults = [.success(CreateOrderResponse(
            pspReference: "ref",
            orderData: "data",
            sessionData: "session_data2"
        ))]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        
        let expectation = expectation(description: "Expect request order API call to be made")
        apiClient.onExecute = { request in
            if request is CreateOrderRequest {
                expectation.fulfill()
            }
        }
        sut.requestOrder(for: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            let order = try! result.get()
            XCTAssertEqual(order.pspReference, "ref")
            XCTAssertEqual(order.orderData, "data")
            XCTAssertEqual(sut.sessionContext.data, "session_data2")
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testRequestOrderFailure() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let apiClient = APIClientMock()
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        
        apiClient.mockedResults = [.failure(PartialPaymentError.missingOrderData)]
        
        let expectation = expectation(description: "Expect request order API call to be made")
        apiClient.onExecute = { request in
            if request is CreateOrderRequest {
                expectation.fulfill()
            }
        }
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        sut.requestOrder(for: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            XCTAssertNotNil(result.failure)
            XCTAssertEqual(sut.sessionContext.data, "session_data_0")
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testCancelOrderSuccess() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let apiClient = APIClientMock()
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        
        apiClient.mockedResults = [.success(CancelOrderResponse(sessionData: "session_data2"))]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        
        let order = PartialPaymentOrder(pspReference: "ref", orderData: nil)
        sut.cancelOrder(order, component: PaymentComponentMock(paymentMethod: paymentMethod))
        
        wait(for: .seconds(1))
        XCTAssertEqual(sut.sessionContext.data, "session_data2")
    }
    
    func testCancelOrderFailure() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let apiClient = APIClientMock()
        let paymentMethod = expectedPaymentMethods.regular.first as! GiftCardPaymentMethod
        
        apiClient.mockedResults = [.failure(PartialPaymentError.missingOrderData)]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        
        let order = PartialPaymentOrder(pspReference: "ref", orderData: nil)
        sut.cancelOrder(order, component: PaymentComponentMock(paymentMethod: paymentMethod))
        
        wait(for: .seconds(1))
        XCTAssertEqual(sut.sessionContext.data, "session_data_0")
    }
    
    func testRemoveStoredPaymentMethodSuccess() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(DisableStoredPaymentMethodResponse())]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        
        let deleteExpectation = expectation(description: "Expect delete call to succeed")
        apiClient.onExecute = { request in
            if request is DisableStoredPaymentMethodRequest {
                deleteExpectation.fulfill()
            }
        }
        
        let stored = expectedPaymentMethods.stored.first as! StoredCardPaymentMethod
        let config = DropInComponent.Configuration()
        let dropIn = DropInComponent(
            paymentMethods: expectedPaymentMethods,
            context: context,
            configuration: config
        )
        sut.disable(storedPaymentMethod: stored, dropInComponent: dropIn) { success in
            XCTAssertTrue(success)
        }
        
        wait(for: [deleteExpectation], timeout: 1)
    }
    
    func testRemoveStoredPaymentMethodFailure() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.failure(Dummy.error)]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        
        let deleteExpectation = expectation(description: "Expect delete call to fail")
        apiClient.onExecute = { request in
            if request is DisableStoredPaymentMethodRequest {
                deleteExpectation.fulfill()
            }
        }
        
        let stored = expectedPaymentMethods.stored.first as! StoredCardPaymentMethod
        let config = DropInComponent.Configuration()
        let dropIn = DropInComponent(
            paymentMethods: expectedPaymentMethods,
            context: context,
            configuration: config
        )
        sut.disable(storedPaymentMethod: stored, dropInComponent: dropIn) { success in
            XCTAssertFalse(success)
        }
        
        wait(for: [deleteExpectation], timeout: 1)
    }
    
    func testSessionAsDropInDelegate() throws {
        let config = DropInComponent.Configuration()

        let paymenMethods = try! JSONDecoder().decode(PaymentMethods.self, from: DropInTests.paymentMethods.data(using: .utf8)!)
        let dropIn = DropInComponent(
            paymentMethods: paymenMethods,
            context: context,
            configuration: config
        )
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sessionDelegate)
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
        
        dropIn.didFail(with: ComponentError.paymentMethodNotSupported, from: paymentComponent)
        dropIn.didOpenExternalApplication(component: QRCodeActionComponent(context: context))
        sut.sessionContext.resultCode = .authorised
        dropIn.didComplete(from: actionComponent)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testResultCodeAuthorised() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let apiClient = APIClientMock()
        let sessionDelegate = SessionDelegateMock()
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .authorised,
                action: nil,
                order: nil,
                sessionData: "session_data",
                sessionResult: "sessionResultString"
            )
        )]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sessionDelegate
        )
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result.resultCode, .authorised)
            XCTAssertEqual(result.sessionResult, "sessionResultString")
            didCompleteExpectation.fulfill()
        }
        let actionData = try ActionComponentData(
            details: RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 1)
    }
    
    func testResultCodePending() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .pending,
                action: nil,
                order: nil,
                sessionData: "session_data",
                sessionResult: nil
            )
        )]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sessionDelegate
        )
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result.resultCode, .pending)
            XCTAssertNil(result.sessionResult)
            didCompleteExpectation.fulfill()
        }
        let actionData = try ActionComponentData(
            details: RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 1)
    }
    
    func testResultCodeRefused() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .refused,
                action: nil,
                order: nil,
                sessionData: "session_data",
                sessionResult: nil
            )
        )]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sessionDelegate
        )
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result.resultCode, .refused)
            XCTAssertNil(result.sessionResult)
            didCompleteExpectation.fulfill()
        }
        let actionData = try ActionComponentData(
            details: RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 1)
    }
    
    func testResultCodeCancelled() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .cancelled,
                action: nil,
                order: nil,
                sessionData: "session_data",
                sessionResult: "sessionResultString"
            )
        )]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sessionDelegate
        )
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result.resultCode, .cancelled)
            XCTAssertEqual(result.sessionResult, "sessionResultString")
            didCompleteExpectation.fulfill()
        }
        let actionData = try ActionComponentData(
            details: RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 1)
    }
    
    func testResultCodeReceived() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .received,
                action: nil,
                order: nil,
                sessionData: "session_data",
                sessionResult: "sessionResultString"
            )
        )]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sessionDelegate
        )
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result.resultCode, .received)
            XCTAssertEqual(result.sessionResult, "sessionResultString")
            didCompleteExpectation.fulfill()
        }
        let actionData = try ActionComponentData(
            details: RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 1)
    }
    
    func testResultCodePresentToShopper() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .presentToShopper,
                action: nil,
                order: nil,
                sessionData: "session_data",
                sessionResult: "sessionResultString"
            )
        )]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sessionDelegate
        )
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result.resultCode, .presentToShopper)
            XCTAssertEqual(result.sessionResult, "sessionResultString")
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
        wait(for: [didCompleteExpectation], timeout: 1)
    }
    
    func testResultCodeError() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .error,
                action: nil,
                order: nil,
                sessionData: "session_data",
                sessionResult: nil
            )
        )]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sessionDelegate
        )
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result.resultCode, .error)
            XCTAssertNil(result.sessionResult)
            didCompleteExpectation.fulfill()
        }
        let actionData = try ActionComponentData(
            details: RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 1)
    }
    
    func testResultCodeErrorFromAnotherCode() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sessionDelegate = SessionDelegateMock()
        let apiClient = APIClientMock()
        
        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .redirectShopper,
                action: nil,
                order: nil,
                sessionData: "session_data",
                sessionResult: "sessionResultString"
            )
        )]
        
        let sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sessionDelegate
        )
        
        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sessionDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result.resultCode, .redirectShopper)
            XCTAssertEqual(result.sessionResult, "sessionResultString")
            didCompleteExpectation.fulfill()
        }
        let actionData = try ActionComponentData(
            details: RedirectDetails(
                returnURL: Dummy.returnUrl
            ),
            paymentData: "payment_data"
        )
        sut.didProvide(actionData, from: QRCodeActionComponent(context: context))
        wait(for: [didCompleteExpectation], timeout: 1)
    }
    
    func testInstallmentsFromSessionConfig() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let config = try! JSONDecoder().decode(SessionSetupResponse.Configuration.self, from: sessionConfigJson.data(using: .utf8)!)
        let sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, configuration: config)
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
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let config = try! JSONDecoder().decode(SessionSetupResponse.Configuration.self, from: sessionConfigJson.data(using: .utf8)!)
        let sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, configuration: config)
        let paymentMethod = expectedPaymentMethods.regular[1] as! CardPaymentMethod
        var cardConfig = CardComponent.Configuration()
        cardConfig.showsStorePaymentMethodField = false // will be overriden as true by session response
        
        let cardComponent = CardComponent(paymentMethod: paymentMethod, context: context)
        cardComponent.delegate = sut
        
        let viewController = cardComponent.viewController
        viewController.loadViewIfNeeded()

        XCTAssertNotNil(cardComponent.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
        XCTAssertTrue(cardComponent.configuration.showsStorePaymentMethodField)
    }
    
    func testStorePaymentMethodFieldNil() throws {
        let expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        let sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, configuration: .init(installmentOptions: nil, enableStoreDetails: false))
        let paymentMethod = expectedPaymentMethods.regular[1] as! CardPaymentMethod
        var cardConfig = CardComponent.Configuration()
        cardConfig.showsStorePaymentMethodField = true // will be overriden as false by session response
        
        let cardComponent = CardComponent(paymentMethod: paymentMethod, context: context)
        cardComponent.delegate = sut
        
        let viewController = cardComponent.viewController
        viewController.loadViewIfNeeded()

        XCTAssertNil(cardComponent.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
        XCTAssertFalse(cardComponent.configuration.showsStorePaymentMethodField)
    }
    
    private func initializeSession(
        expectedPaymentMethods: PaymentMethods,
        apiClient: APIClientMock = APIClientMock(),
        delegate: AdyenSessionDelegate = SessionDelegateMock(),
        configuration: SessionSetupResponse.Configuration = .init(installmentOptions: nil, enableStoreDetails: true)
    ) -> AdyenSession {
        let sessionConfig = AdyenSession.Configuration(
            sessionIdentifier: "session_id",
            initialSessionData: "session_data_0"
        )
        let sessionContext = AdyenSession.Context(
            data: "session_data_0",
            identifier: "session_id",
            countryCode: "US",
            shopperLocale: "US",
            amount: context.amount,
            paymentMethods: expectedPaymentMethods,
            responseConfiguration: configuration
        )
        let sut = AdyenSession(
            configuration: sessionConfig,
            sessionContext: sessionContext,
            baseAPIClient: apiClient,
            actionHandlingComponent: ActionHandlingComponentMock(),
            delegate: delegate
        )
        
        return sut
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
