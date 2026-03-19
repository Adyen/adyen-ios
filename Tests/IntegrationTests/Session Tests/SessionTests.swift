//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import AdyenSession
@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
@testable import AdyenCard
import AdyenComponents
@testable import AdyenDropIn
@testable import AdyenEncryption
import AdyenNetworking

@MainActor
class SessionTests: XCTestCase {

    var analyticsProviderMock: AnalyticsProviderMock!
    var context: AdyenContext!
    var sut: Session!
    var sutDelegate: SessionDelegateMock!
    var expectedPaymentMethods: PaymentMethods!

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsProviderMock = AnalyticsProviderMock(checkoutAttemptId: "d06da733-ec41-4739-a532-5e8deab1262e16547639430681e1b021221a98c4bf13f7366b30fec4b376cc8450067ff98998682dd24fc9bda")
        context = Dummy.context(analyticsProvider: analyticsProviderMock)

        expectedPaymentMethods = try AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        sutDelegate = SessionDelegateMock()
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
        sutDelegate = nil
        sut = nil
        expectedPaymentMethods = nil
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

    func testInitialization() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(SessionSetupResponse(
            countryCode: "US",
            shopperLocale: "US",
            paymentMethods: expectedPaymentMethods,
            amount: .init(value: 220, currencyCode: "USD"),
            sessionData: "session_data_1",
            configuration: .init(installmentOptions: nil, enableStoreDetails: false)
        ))]

        let session = try await Session.setup(
            with: .init(
                id: "session_id",
                sessionData: "session_data_0"
            ),
            apiClient: apiClient,
            context: context
        )

        XCTAssertEqual(session.state.identifier, "session_id")
        XCTAssertEqual(session.state.data, "session_data_1")
        XCTAssertEqual(session.state.shopperLocale, "US")
        XCTAssertEqual(session.state.countryCode, "US")
        XCTAssertEqual(session.state.paymentMethods, self.expectedPaymentMethods)
        XCTAssertEqual(session.state.amount, .init(value: 220, currencyCode: "USD"))
        XCTAssertFalse(session.state.responseConfiguration.enableStoreDetails)
        XCTAssertFalse(session.state.responseConfiguration.showRemovePaymentMethodButton)
        XCTAssertEqual(AnalyticsForSession.sessionId, "session_id")
        XCTAssertTrue(session.isSession)
        XCTAssertEqual(session.showStorePaymentMethodField, session.state.responseConfiguration.enableStoreDetails)

    }

    func testDidSubmitWithNoActionAndNoOrder() throws {
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.last as? MBWayPaymentMethod)
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

        sut = initializeSession(
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
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.last as? MBWayPaymentMethod)
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

        let expectedAction = try RedirectAction(
            url: XCTUnwrap(URL(string: "https://google.com")),
            paymentData: "payment_data"
        )
        let apiClient = APIClientMock()
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

        sut = initializeSession(
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
                self.sut.didProvide(data, from: RedirectComponent(context: self.context))
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
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.last as? MBWayPaymentMethod)
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        sut.didSubmit(data, from: component, in: dropInComponent)
        wait(for: [apiCallsExpectation], timeout: 1)

        let stateUpdatedExpectation = expectation(description: "Expect state to be updated")
        stateUpdatedExpectation.isInverted = true
        wait(for: [stateUpdatedExpectation], timeout: 0.5)

        XCTAssertEqual(sut.state.amount, expectedAmount)
        XCTAssertEqual(sut.state.countryCode, "EG")
        XCTAssertEqual(sut.state.shopperLocale, "EG")
        XCTAssertEqual(sut.state.data, "session_data_xxx")
        XCTAssertNil(sut.state.responseConfiguration.installmentOptions)
        XCTAssertTrue(sut.state.responseConfiguration.enableStoreDetails)
        XCTAssertTrue(sut.state.responseConfiguration.showRemovePaymentMethodButton)
    }

    func testDidSubmitFailure() throws {
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.last as? MBWayPaymentMethod)
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
        sut = initializeSession(
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
        let dropInComponent = DropInComponent(
            paymentMethods: expectedPaymentMethods,
            context: context,
            title: nil
        )

        let viewController = dropInComponent.viewController
        viewController.loadViewIfNeeded()

        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.last as? MBWayPaymentMethod)
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

        sut = initializeSession(
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
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)
        let details = GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc")
        let paymentData = PaymentComponentData(paymentMethodDetails: details, amount: nil, order: nil)
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(BalanceCheckResponse(
            sessionData: "session_data2",
            balance: Amount(value: 50, currencyCode: "EUR"),
            transactionLimit: Amount(value: 30, currencyCode: "EUR")
        ))]

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )

        let expectation = expectation(description: "Expect check balance API call to be made")
        apiClient.onExecute = { request in
            if request is BalanceCheckRequest {
                expectation.fulfill()
            }
        }
        let completionExpectation = self.expectation(description: "Expect completion to be called")
        sut.checkBalance(with: paymentData, component: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            let balance = try! result.get()
            XCTAssertEqual(balance.availableAmount.value, 50)
            XCTAssertEqual(balance.transactionLimit!.value, 30)
            XCTAssertEqual(self.sut.state.data, "session_data2")
            completionExpectation.fulfill()
        }
        wait(for: [expectation, completionExpectation], timeout: 5)
    }

    func testBalanceCheckZeroBalance() throws {
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        let completionExpectation = self.expectation(description: "Expect completion to be called")
        // get .failure
        sut.checkBalance(with: paymentData, component: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            XCTAssertNotNil(result.failure)
            XCTAssertEqual(self.sut.state.data, "session_data2")
            completionExpectation.fulfill()
        }
        wait(for: [expectation, completionExpectation], timeout: 1)
    }

    func testBalanceCheckFailure() throws {
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        let completionExpectation = self.expectation(description: "Expect completion to be called")
        // get .failure
        sut.checkBalance(with: paymentData, component: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            XCTAssertNotNil(result.failure)
            XCTAssertEqual(self.sut.state.data, "session_data_0")
            completionExpectation.fulfill()
        }
        wait(for: [expectation, completionExpectation], timeout: 1)
    }

    func testRequestOrderSuccess() throws {
        let apiClient = APIClientMock()
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)

        apiClient.mockedResults = [.success(CreateOrderResponse(
            pspReference: "ref",
            orderData: "data",
            sessionData: "session_data2"
        ))]

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )

        let expectation = expectation(description: "Expect request order API call to be made")
        apiClient.onExecute = { request in
            if request is CreateOrderRequest {
                expectation.fulfill()
            }
        }
        let completionExpectation = self.expectation(description: "Expect completion to be called")
        sut.requestOrder(for: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            let order = try! result.get()
            XCTAssertEqual(order.pspReference, "ref")
            XCTAssertEqual(order.orderData, "data")
            XCTAssertEqual(self.sut.state.data, "session_data2")
            completionExpectation.fulfill()
        }
        wait(for: [expectation, completionExpectation], timeout: 1)
    }

    func testRequestOrderFailure() throws {
        let apiClient = APIClientMock()
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)

        apiClient.mockedResults = [.failure(PartialPaymentError.missingOrderData)]

        let expectation = expectation(description: "Expect request order API call to be made")
        apiClient.onExecute = { request in
            if request is CreateOrderRequest {
                expectation.fulfill()
            }
        }

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )
        let completionExpectation = self.expectation(description: "Expect completion to be called")
        sut.requestOrder(for: PaymentComponentMock(paymentMethod: paymentMethod)) { result in
            XCTAssertNotNil(result.failure)
            XCTAssertEqual(self.sut.state.data, "session_data_0")
            completionExpectation.fulfill()
        }
        wait(for: [expectation, completionExpectation], timeout: 1)
    }

    func testCancelOrderSuccess() throws {
        let apiClient = APIClientMock()
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)

        apiClient.mockedResults = [.success(CancelOrderResponse(sessionData: "session_data2"))]

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )

        let order = PartialPaymentOrder(pspReference: "ref", orderData: nil)
        sut.cancelOrder(order, component: PaymentComponentMock(paymentMethod: paymentMethod))

        wait(for: .seconds(1))
        XCTAssertEqual(sut.state.data, "session_data2")
    }

    func testCancelOrderFailure() throws {
        let apiClient = APIClientMock()
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)

        apiClient.mockedResults = [.failure(PartialPaymentError.missingOrderData)]

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )

        let order = PartialPaymentOrder(pspReference: "ref", orderData: nil)
        sut.cancelOrder(order, component: PaymentComponentMock(paymentMethod: paymentMethod))

        wait(for: .seconds(1))
        XCTAssertEqual(sut.state.data, "session_data_0")
    }

    func testRemoveStoredPaymentMethodSuccess() throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(EmptyResponse())]

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )

        let deleteExpectation = expectation(description: "Expect delete call to succeed")
        apiClient.onExecute = { request in
            if request is DisableStoredPaymentMethodRequest {
                deleteExpectation.fulfill()
            }
        }

        let stored = try XCTUnwrap(expectedPaymentMethods.stored.first as? StoredCardPaymentMethod)
        let config = DropInComponent.Configuration()
        let dropIn = DropInComponent(
            paymentMethods: expectedPaymentMethods,
            context: context,
            configuration: config
        )
        let completionExpectation = self.expectation(description: "Expect completion to be called")
        sut.disable(storedPaymentMethod: stored, dropInComponent: dropIn) { success in
            XCTAssertTrue(success)
            completionExpectation.fulfill()
        }

        wait(for: [deleteExpectation, completionExpectation], timeout: 1)
    }

    func testRemoveStoredPaymentMethodFailure() throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.failure(Dummy.error)]

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient
        )

        let deleteExpectation = expectation(description: "Expect delete call to fail")
        apiClient.onExecute = { request in
            if request is DisableStoredPaymentMethodRequest {
                deleteExpectation.fulfill()
            }
        }

        let stored = try XCTUnwrap(expectedPaymentMethods.stored.first as? StoredCardPaymentMethod)
        let config = DropInComponent.Configuration()
        let dropIn = DropInComponent(
            paymentMethods: expectedPaymentMethods,
            context: context,
            configuration: config
        )
        let completionExpectation = self.expectation(description: "Expect completion to be called")
        sut.disable(storedPaymentMethod: stored, dropInComponent: dropIn) { success in
            XCTAssertFalse(success)
            completionExpectation.fulfill()
        }

        wait(for: [deleteExpectation, completionExpectation], timeout: 1)
    }

    func testSessionAsDropInDelegate() throws {
        let config = DropInComponent.Configuration()

        let dropIn = DropInComponent(
            paymentMethods: expectedPaymentMethods,
            context: context,
            configuration: config
        )
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, delegate: sutDelegate)
        dropIn.delegate = sut

        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)
        let paymentComponent = PaymentComponentMock(paymentMethod: paymentMethod)
        let actionComponent = QRCodeActionComponent(context: context)

        let didFailExpectation = expectation(description: "didFail should be called")
        sutDelegate.onDidFail = { error, component, session in
            XCTAssertTrue(error is ComponentError)
            XCTAssertTrue(session === self.sut)
            didFailExpectation.fulfill()
        }

        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sutDelegate.onDidComplete = { result, component, session in
            XCTAssertTrue(session === self.sut)
            didCompleteExpectation.fulfill()
        }

        let didOpenExternalAppExpectation = expectation(description: "didOpenExternalApplication should be called")
        sutDelegate.onDidOpenExternalApplication = {
            didOpenExternalAppExpectation.fulfill()
        }

        dropIn.delegate?.didFail(with: ComponentError.paymentMethodNotSupported, from: paymentComponent, in: dropIn)
        dropIn.delegate?.didOpenExternalApplication(component: QRCodeActionComponent(context: context), in: dropIn)
        sut.state.resultCode = .authorised
        dropIn.delegate?.didComplete(from: actionComponent, in: dropIn)

        wait(for: [didFailExpectation, didCompleteExpectation, didOpenExternalAppExpectation], timeout: 2)
    }

    func testResultCodeAuthorised() throws {
        let apiClient = APIClientMock()

        apiClient.mockedResults = [.success(
            PaymentsResponse(
                resultCode: .authorised,
                action: nil,
                order: nil,
                sessionData: "session_data",
                sessionResult: "sessionResultString"
            )
        )]

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sutDelegate
        )

        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sutDelegate.onDidComplete = { result, _, _ in
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sutDelegate
        )

        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sutDelegate.onDidComplete = { result, _, _ in
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sutDelegate
        )

        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sutDelegate.onDidComplete = { result, _, _ in
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sutDelegate
        )

        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sutDelegate.onDidComplete = { result, _, _ in
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sutDelegate
        )

        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sutDelegate.onDidComplete = { result, _, _ in
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sutDelegate
        )

        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sutDelegate.onDidComplete = { result, _, _ in
            XCTAssertEqual(result.resultCode, .presentToShopper)
            XCTAssertEqual(result.sessionResult, "sessionResultString")
            didCompleteExpectation.fulfill()
        }
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sutDelegate
        )

        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sutDelegate.onDidComplete = { result, _, _ in
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

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            apiClient: apiClient,
            delegate: sutDelegate
        )

        let didCompleteExpectation = expectation(description: "didComplete should be called")
        sutDelegate.onDidComplete = { result, _, _ in
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
        let config = try JSONDecoder().decode(SessionSetupResponse.Configuration.self, from: XCTUnwrap(sessionConfigJson.data(using: .utf8)))
        let sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, configuration: config)
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular[1] as? CardPaymentMethod)
        let cardConfig = CardComponentConfiguration()
            .installmentConfiguration(.init(cardBasedOptions: [.americanExpress: .init(maxInstallmentMonth: 5, includesRevolving: false)], defaultOptions: .init(monthValues: [3, 5], includesRevolving: true)))
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
        let config = try JSONDecoder().decode(SessionSetupResponse.Configuration.self, from: XCTUnwrap(sessionConfigJson.data(using: .utf8)))
        let sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, configuration: config)
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular[1] as? CardPaymentMethod)
        let cardConfig = CardComponentConfiguration()
            .showsStorePaymentMethodField(false) // will be overriden as true by session response

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
        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular[1] as? CardPaymentMethod)
        let cardConfig = CardComponentConfiguration()
            .showsStorePaymentMethodField(true) // will be overriden as false by session response

        let cardComponent = CardComponent(paymentMethod: paymentMethod, context: context)
        cardComponent.delegate = sut

        let viewController = cardComponent.viewController
        viewController.loadViewIfNeeded()

        XCTAssertNil(cardComponent.viewController.view.findView(with: "AdyenCard.CardComponent.storeDetailsItem"))
        XCTAssertFalse(cardComponent.configuration.showsStorePaymentMethodField)
    }

    func testPaymentsRequestEncodesInstallments() throws {
        // Given
        let cardDetails = makeTestCardDetails()
        let installments = Installments(totalMonths: 3, plan: .regular)
        let data = PaymentComponentData(
            paymentMethodDetails: cardDetails,
            amount: nil,
            order: nil,
            installments: installments
        )

        // When
        let request = PaymentsRequest(
            sessionId: "session_id",
            sessionData: "session_data",
            data: data
        )
        let encodedData = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: encodedData) as? [String: Any])

        // Then
        let installmentsJson = try XCTUnwrap(json["installments"] as? [String: Any])
        XCTAssertEqual(installmentsJson["value"] as? Int, 3)
        XCTAssertEqual(installmentsJson["plan"] as? String, "regular")
    }

    func testPaymentsRequestOmitsInstallmentsWhenNil() throws {
        // Given
        let cardDetails = makeTestCardDetails()
        let data = PaymentComponentData(
            paymentMethodDetails: cardDetails,
            amount: nil,
            order: nil
        )

        // When
        let request = PaymentsRequest(
            sessionId: "session_id",
            sessionData: "session_data",
            data: data
        )
        let encodedData = try JSONEncoder().encode(request)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: encodedData) as? [String: Any])

        // Then
        XCTAssertNil(json["installments"])
    }

    private func initializeSession(
        expectedPaymentMethods: PaymentMethods,
        apiClient: APIClientMock = APIClientMock(),
        delegate: SessionDelegate = SessionDelegateMock(),
        configuration: SessionSetupResponse.Configuration = .init(installmentOptions: nil, enableStoreDetails: true)
    ) -> Session {
        let sessionState = Session.State(
            data: "session_data_0",
            identifier: "session_id",
            countryCode: "US",
            shopperLocale: "US",
            amount: context.amount!,
            paymentMethods: expectedPaymentMethods,
            responseConfiguration: configuration
        )
        return Session(
            state: sessionState,
            baseAPIClient: apiClient,
            context: context,
            delegate: delegate
        )
    }
    
    private func makeTestCardDetails() -> CardDetails {
        let paymentMethod = CardPaymentMethodMock(fundingSource: .credit, type: .other("test_type"), name: "test name", brands: [.visa, .bcmc])
        let encryptedCard = EncryptedCard(number: "number", securityCode: "code", expiryMonth: "month", expiryYear: "year")
        return CardDetails(paymentMethod: paymentMethod, encryptedCard: encryptedCard)
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
