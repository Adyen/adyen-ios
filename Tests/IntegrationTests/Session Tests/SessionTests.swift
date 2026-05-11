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
@testable import AdyenEncryption
import AdyenNetworking

@MainActor
class SessionTests: XCTestCase {

    var analyticsProviderMock: AnalyticsProviderMock!
    var context: AdyenContext!
    var sut: Session!
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
    }

    override func tearDownWithError() throws {
        analyticsProviderMock = nil
        context = nil
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

    func test_asSubmitResult_withCompletionResponse_shouldReturnCompletion() {
        let response = PaymentsResponse(
            resultCode: .authorised,
            action: nil,
            order: nil,
            sessionData: "session_data",
            sessionResult: "sessionResultString"
        )
        
        let result = response.asSubmitResult(paymentMethods: expectedPaymentMethods)
        
        switch result {
        case let .completion(resultCode):
            XCTAssertEqual(resultCode, CheckoutResultCode.authorised.rawValue)
        default:
            XCTFail("Expected completion result")
        }
    }
    
    func test_asSubmitResult_withActionResponse_shouldReturnAction() throws {
        let action = try RedirectAction(
            url: XCTUnwrap(URL(string: "https://google.com")),
            paymentData: "payment_data"
        )
        let response = PaymentsResponse(
            resultCode: .redirectShopper,
            action: .redirect(action),
            order: nil,
            sessionData: "session_data",
            sessionResult: nil
        )
        
        let result = response.asSubmitResult(paymentMethods: expectedPaymentMethods)
        
        switch result {
        case .action:
            break
        default:
            XCTFail("Expected action result")
        }
    }
    
    func test_asSubmitResult_withPartialPaymentOrder_shouldReturnPartialPayment() {
        let order = PartialPaymentOrder(
            pspReference: "pspReference",
            orderData: "order_data",
            reference: "reference",
            amount: .init(value: 220, currencyCode: "USD", localeIdentifier: nil),
            remainingAmount: .init(value: 20, currencyCode: "USD", localeIdentifier: nil),
            expiresAt: Date()
        )
        let response = PaymentsResponse(
            resultCode: .received,
            action: nil,
            order: order,
            sessionData: "session_data",
            sessionResult: nil
        )
        
        let result = response.asSubmitResult(paymentMethods: expectedPaymentMethods)
        
        switch result {
        case let .partialPayment(partialPayment):
            XCTAssertEqual(partialPayment.order, order)
            XCTAssertEqual(partialPayment.paymentMethods.regular.count, expectedPaymentMethods.regular.count)
            XCTAssertEqual(partialPayment.paymentMethods.stored.count, expectedPaymentMethods.stored.count)
        default:
            XCTFail("Expected partial payment result")
        }
    }
    
    func test_asAdditionalDetailsResult_withCompletionResponse_shouldReturnCompletion() throws {
        let response = PaymentsResponse(
            resultCode: .authorised,
            action: nil,
            order: nil,
            sessionData: "session_data",
            sessionResult: "sessionResultString"
        )
        
        let result = try response.asAdditionalDetailsResult()
        
        switch result {
        case let .completion(resultCode):
            XCTAssertEqual(resultCode, CheckoutResultCode.authorised.rawValue)
        }
    }
    
    func test_asAdditionalDetailsResult_withActionResponse_shouldThrowUnsupportedActionAfterDetails() throws {
        let action = try RedirectAction(
            url: XCTUnwrap(URL(string: "https://google.com")),
            paymentData: "payment_data"
        )
        let response = PaymentsResponse(
            resultCode: .redirectShopper,
            action: .redirect(action),
            order: nil,
            sessionData: "session_data",
            sessionResult: nil
        )
        
        XCTAssertThrowsError(try response.asAdditionalDetailsResult()) { error in
            if case .unsupportedActionAfterDetails? = error as? SessionError {
                return
            }
            XCTFail("Expected SessionError.unsupportedActionAfterDetails")
        }
    }
    
    // MARK: - performSubmit

    func test_performSubmit_withCompletionResponse_shouldReturnCompletion() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(PaymentsResponse(
            resultCode: .authorised,
            action: nil,
            order: nil,
            sessionData: "session_data",
            sessionResult: "sessionResultString"
        ))]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.last as? MBWayPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "telephone"),
            amount: nil,
            order: nil
        )

        let result = try await sut.performSubmit(data)
        switch result {
        case let .completion(resultCode):
            XCTAssertEqual(resultCode, CheckoutResultCode.authorised.rawValue)
        default:
            XCTFail("Expected completion result")
        }
    }

    func test_performSubmit_withActionResponse_shouldReturnAction() async throws {
        let expectedAction = try RedirectAction(
            url: XCTUnwrap(URL(string: "https://google.com")),
            paymentData: "payment_data"
        )
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(PaymentsResponse(
            resultCode: .redirectShopper,
            action: .redirect(expectedAction),
            order: nil,
            sessionData: "session_data",
            sessionResult: nil
        ))]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.last as? MBWayPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "telephone"),
            amount: nil,
            order: nil
        )

        let result = try await sut.performSubmit(data)
        switch result {
        case let .action(action):
            if case let .redirect(redirect) = action {
                XCTAssertEqual(redirect.url, expectedAction.url)
            } else {
                XCTFail("Expected redirect action")
            }
        default:
            XCTFail("Expected action result")
        }
    }

    func test_performSubmit_withPartialPaymentOrder_shouldUpdateStateAndReturn() async throws {
        let expectedOrder = PartialPaymentOrder(
            pspReference: "pspReference",
            orderData: "order_data",
            reference: "reference",
            amount: .init(value: 220, currencyCode: "USD", localeIdentifier: nil),
            remainingAmount: .init(value: 20, currencyCode: "USD", localeIdentifier: nil),
            expiresAt: Date()
        )
        let expectedAmount = Amount(value: 440, currencyCode: "EGP", localeIdentifier: nil)
        let apiClient = APIClientMock()
        apiClient.mockedResults = [
            .success(PaymentsResponse(
                resultCode: .authorised,
                action: nil,
                order: expectedOrder,
                sessionData: "session_data",
                sessionResult: "sessionResultString"
            )),
            .success(SessionSetupResponse(
                countryCode: "EG",
                shopperLocale: "EG",
                paymentMethods: expectedPaymentMethods,
                amount: expectedAmount,
                sessionData: "session_data_xxx",
                configuration: .init(installmentOptions: nil, enableStoreDetails: true, showRemovePaymentMethodButton: true)
            ))
        ]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.last as? MBWayPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "telephone"),
            amount: nil,
            order: nil
        )

        let result = try await sut.performSubmit(data)
        switch result {
        case let .partialPayment(partialPayment):
            XCTAssertEqual(partialPayment.order, expectedOrder)
        default:
            XCTFail("Expected partial payment result")
        }

        XCTAssertEqual(sut.state.amount, expectedAmount)
        XCTAssertEqual(sut.state.countryCode, "EG")
        XCTAssertEqual(sut.state.data, "session_data_xxx")
        XCTAssertTrue(sut.state.responseConfiguration.enableStoreDetails)
        XCTAssertTrue(sut.state.responseConfiguration.showRemovePaymentMethodButton)
    }

    func test_performSubmit_withAPIFailure_shouldThrow() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.failure(Dummy.error)]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.last as? MBWayPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: MBWayDetails(paymentMethod: paymentMethod, telephoneNumber: "telephone"),
            amount: nil,
            order: nil
        )

        do {
            _ = try await sut.performSubmit(data)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is Dummy)
        }
    }

    // MARK: - performAdditionalDetails

    func test_performAdditionalDetails_withCompletionResponse_shouldReturnCompletion() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(PaymentsResponse(
            resultCode: .authorised,
            action: nil,
            order: nil,
            sessionData: "session_data",
            sessionResult: "sessionResultString"
        ))]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let data = try ActionComponentData(
            details: RedirectDetails(returnURL: Dummy.returnUrl),
            paymentData: "payment_data"
        )

        let result = try await sut.performAdditionalDetails(data)
        switch result {
        case let .completion(resultCode):
            XCTAssertEqual(resultCode, CheckoutResultCode.authorised.rawValue)
        }
    }

    // MARK: - performBalanceCheck

    func test_performBalanceCheck_withBalance_shouldReturnBalance() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(BalanceCheckResponse(
            sessionData: "session_data_2",
            balance: Amount(value: 50, currencyCode: "EUR"),
            transactionLimit: Amount(value: 30, currencyCode: "EUR")
        ))]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc"),
            amount: nil,
            order: nil
        )

        let balance = try await sut.performBalanceCheck(with: data)
        XCTAssertEqual(balance.availableAmount.value, 50)
        XCTAssertEqual(balance.transactionLimit?.value, 30)
        XCTAssertEqual(sut.state.data, "session_data_2")
    }

    func test_performBalanceCheck_withZeroBalance_shouldThrow() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(BalanceCheckResponse(
            sessionData: "session_data_2",
            balance: nil,
            transactionLimit: nil
        ))]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc"),
            amount: nil,
            order: nil
        )

        do {
            _ = try await sut.performBalanceCheck(with: data)
            XCTFail("Expected zeroBalance error")
        } catch {
            XCTAssertTrue(error is BalanceChecker.Error)
        }
    }

    func test_performBalanceCheck_withAPIFailure_shouldThrow() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.failure(Dummy.error)]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let paymentMethod = try XCTUnwrap(expectedPaymentMethods.regular.first as? GiftCardPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: GiftCardDetails(paymentMethod: paymentMethod, encryptedCardNumber: "card", encryptedSecurityCode: "cvc"),
            amount: nil,
            order: nil
        )

        do {
            _ = try await sut.performBalanceCheck(with: data)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is Dummy)
        }
    }

    // MARK: - requestOrder

    func test_requestOrder_withSuccess_shouldReturnOrder() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(CreateOrderResponse(
            pspReference: "ref",
            orderData: "data",
            sessionData: "session_data_2"
        ))]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let order = try await sut.requestOrder()
        XCTAssertEqual(order.pspReference, "ref")
        XCTAssertEqual(order.orderData, "data")
        XCTAssertEqual(sut.state.data, "session_data_2")
    }

    func test_requestOrder_withAPIFailure_shouldThrow() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.failure(Dummy.error)]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        do {
            _ = try await sut.requestOrder()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is Dummy)
        }
    }

    // MARK: - cancelOrder

    func test_cancelOrder_withSuccess_shouldUpdateSessionData() async {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(CancelOrderResponse(sessionData: "session_data_2"))]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let order = PartialPaymentOrder(pspReference: "ref", orderData: nil)
        await sut.cancelOrder(order)
        XCTAssertEqual(sut.state.data, "session_data_2")
    }

    func test_cancelOrder_withAPIFailure_shouldNotCrash() async {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.failure(Dummy.error)]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let order = PartialPaymentOrder(pspReference: "ref", orderData: nil)
        await sut.cancelOrder(order)
        XCTAssertEqual(sut.state.data, "session_data_0")
    }

    // MARK: - disable

    func test_disable_withSuccess_shouldNotThrow() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.success(EmptyResponse())]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let stored = try XCTUnwrap(expectedPaymentMethods.stored.first as? StoredCardPaymentMethod)
        try await sut.disable(storedPaymentMethod: stored)
    }

    func test_disable_withAPIFailure_shouldThrow() async throws {
        let apiClient = APIClientMock()
        apiClient.mockedResults = [.failure(Dummy.error)]
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, apiClient: apiClient)

        let stored = try XCTUnwrap(expectedPaymentMethods.stored.first as? StoredCardPaymentMethod)
        do {
            try await sut.disable(storedPaymentMethod: stored)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is Dummy)
        }
    }

    // MARK: - Component Configuration Awareness

    func test_installmentConfiguration_shouldReturnSessionConfig() throws {
        let config = try JSONDecoder().decode(
            SessionSetupResponse.Configuration.self,
            from: XCTUnwrap(sessionConfigJson.data(using: .utf8))
        )
        sut = initializeSession(expectedPaymentMethods: expectedPaymentMethods, configuration: config)

        XCTAssertNotNil(sut.installmentConfiguration)
        XCTAssertEqual(
            sut.installmentConfiguration?.defaultOptions,
            .init(monthValues: [2, 3, 5], includesRevolving: false)
        )
        XCTAssertEqual(
            sut.installmentConfiguration?.cardBasedOptions,
            [.visa: .init(monthValues: [3, 6, 9], includesRevolving: true)]
        )
    }

    func test_showStorePaymentMethodField_shouldReflectSessionConfig() {
        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            configuration: .init(installmentOptions: nil, enableStoreDetails: true)
        )
        XCTAssertEqual(sut.showStorePaymentMethodField, true)

        sut = initializeSession(
            expectedPaymentMethods: expectedPaymentMethods,
            configuration: .init(installmentOptions: nil, enableStoreDetails: false)
        )
        XCTAssertEqual(sut.showStorePaymentMethodField, false)
    }

    // MARK: - PaymentsRequest encoding

    func test_paymentsRequest_withInstallments_shouldEncodeInstallments() throws {
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

    func test_paymentsRequest_withNilInstallments_shouldOmitInstallments() throws {
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
            context: context
        )
    }
    
    private func makeTestCardDetails() -> CardDetails {
        let paymentMethod = CardPaymentMethodMock(fundingSource: .credit, type: .other("test_type"), name: "test name", brands: [.visa, .bcmc])
        let encryptedCard = EncryptedCard(number: "number", securityCode: "code", expiryMonth: "month", expiryYear: "year")
        return CardDetails(paymentMethod: paymentMethod, encryptedCard: encryptedCard)
    }
}

private let sessionConfigJson = """
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
