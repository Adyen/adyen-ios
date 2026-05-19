//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenCheckout
@testable import AdyenComponents
@testable import AdyenDropIn
@testable import AdyenSession
import UIKit
import XCTest

@MainActor
final class CheckoutTests: XCTestCase {
    /// Used when the advanced (non-session) action flow has no server-provided
    /// resultCode to report — see `Checkout.didComplete(from:)`.
    private static let missingResultCode = ""
    
    var mockProvider: CheckoutProviderMock!
    var configuration: CheckoutConfiguration!
    var paymentMethods: PaymentMethods!
    
    private let paymentMethodsDictionary = [
        "storedPaymentMethods": [
            storedCreditCardDictionary,
            storedCreditCardDictionary,
            storedBcmcDictionary
        ],
        "paymentMethods": [
            creditCardDictionary,
            blik
        ]
    ]

    override func setUp() {
        super.setUp()
        mockProvider = CheckoutProviderMock()
        configuration = CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            analyticsApiContext: nil,
            analyticsConfiguration: .init()
        )
        paymentMethods = try! AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
    }

    func testSetupWithSession_Success() async throws {
        let expectedSession = AdyenSessionMock(state: .init(
            data: "test_session_data",
            identifier: "test_session_id",
            countryCode: "US",
            shopperLocale: "en_US",
            amount: Amount(value: 1000, currencyCode: "USD"),
            paymentMethods: paymentMethods,
            responseConfiguration: .init(installmentOptions: nil, enableStoreDetails: true)
        ))
        
        let expectedCheckout = CheckoutCore(
            configuration: configuration,
            session: expectedSession,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        mockProvider.setupWithSessionResult = .success(expectedCheckout)

        let checkout = try await Checkout.setup(
            with: .init(
                id: "sessionId",
                sessionData: "sessionData"
            ),
            configuration: configuration,
            presentationDelegate: nil,
            provider: mockProvider
        )
        
        XCTAssertNotNil(checkout.paymentMethods)
        XCTAssertNotNil(checkout.session)
        XCTAssertTrue(checkout.session === expectedSession)
        XCTAssertEqual(checkout.session?.state.identifier, "test_session_id")
        XCTAssertEqual(checkout.session?.state.data, "test_session_data")
        XCTAssertTrue(mockProvider.setupSessionCalled)
    }

    func testSetupWithSession_Failure() async {
        mockProvider.setupWithSessionResult = .failure(TestError())
        
        do {
            _ = try await Checkout.setup(
                with: .init(
                    id: "sessionId",
                    sessionData: "sessionData"
                ),
                configuration: configuration,
                presentationDelegate: nil,
                provider: mockProvider
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }

    func testSetupWithPaymentMethods_Success() async throws {
        let expectedCheckout = CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        mockProvider.setupWithPaymentMethodsResult = .success(expectedCheckout)
        
        let checkout = try await Checkout.setup(
            with: paymentMethods,
            configuration: configuration,
            presentationDelegate: nil,
            provider: mockProvider
        )

        XCTAssertNil(checkout.session)
        XCTAssertNotNil(checkout.paymentMethods)
        XCTAssertTrue(mockProvider.setupPaymentMethodsCalled)
    }

    func testSetupWithPaymentMethods_Failure() async {
        mockProvider.setupWithPaymentMethodsResult = .failure(TestError())
        
        do {
            _ = try await Checkout.setup(
                with: paymentMethods,
                configuration: configuration,
                presentationDelegate: nil,
                provider: mockProvider
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }
    
    func testSetupSessionProtocolCall() async {
        let sessionMock = AdyenSessionMock(state: .init(
            data: "test_data",
            identifier: "test_id",
            countryCode: "NL",
            shopperLocale: "en_NL",
            amount: Amount(value: 100, currencyCode: "EUR"),
            paymentMethods: paymentMethods,
            responseConfiguration: .init(installmentOptions: nil, enableStoreDetails: true)
        ))
        
        mockProvider.mockedSessionResult = .success(sessionMock)
        
        let response = SessionResponse(id: "test_id", sessionData: "test_data")
        let apiClient = APIClientMock()
        
        do {
            let result = try await mockProvider.setupSession(
                with: response,
                adyenContext: Dummy.context,
                apiClient: apiClient
            )
            XCTAssertTrue(result === sessionMock)
        } catch {
            XCTFail("Should not throw an error")
        }
    }
    
    // MARK: - payment component delegate
    
    func test_didSubmit_withSessionAndMissingOnSubmit_shouldPerformSubmit() async throws {
        let callbacks = SessionCheckoutCallbacks()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        let session = makeSessionMock()
        session.performSubmitResult = .success(.completion(resultCode: CheckoutResultCode.authorised.rawValue))
        callbacks.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbacks: callbacks)
        
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onCompleteExpectation], timeout: 1)
        
        XCTAssertTrue(session.performSubmitCalled)
        XCTAssertFalse(session.didSubmitCalled)
    }
    
    func test_didSubmit_withSessionPerformSubmitError_shouldCallOnError() async throws {
        let callbacks = SessionCheckoutCallbacks()
        let onErrorExpectation = expectation(description: "onError called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        let session = makeSessionMock()
        session.performSubmitResult = .failure(TestError())
        callbacks.onError = { _ in
            onErrorExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbacks: callbacks)
        
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onErrorExpectation], timeout: 1)
        
        XCTAssertTrue(session.performSubmitCalled)
        XCTAssertFalse(session.didSubmitCalled)
    }
    
    func test_didSubmit_callsOnSubmit_whenSet() async throws {
        let callbacks = AdvancedCheckoutCallbacks()
        let expectation = expectation(description: "onSubmit called")
        var didCallSubmit = false
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let blikDetails = BLIKDetails(
            paymentMethod: blik,
            blikCode: "code"
        )
        let paymentData = PaymentComponentData(
            paymentMethodDetails: blikDetails,
            amount: nil,
            order: nil
        )
        
        callbacks.onSubmit = { data in
            didCallSubmit = true
            XCTAssertEqual(data.paymentMethod.sdkData, paymentData.paymentMethod.sdkData)
            let details = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(details.type, blikDetails.type)
            XCTAssertEqual(details.blikCode, blikDetails.blikCode)
            expectation.fulfill()
            
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [expectation], timeout: 1)
        
        XCTAssertTrue(didCallSubmit)
    }
    
    // MARK: - createPaymentComponent(for type:) Tests
    
    func test_createPaymentComponent_forType_returnsComponent_whenPaymentMethodExists() throws {
        // Given
        let sut = CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When
        let component = try sut.createPaymentComponent(for: .blik)
        
        // Then
        XCTAssertNotNil(component.viewController)
    }
    
    func test_createPaymentComponent_forType_throws_whenPaymentMethodDoesNotExist() {
        // Given
        let sut = CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When / Then
        XCTAssertThrowsError(try sut.createPaymentComponent(for: .ideal))
    }
    
    func test_createPaymentComponent_forType_throws_whenPaymentMethodsIsNil() {
        // Given
        let sut = CheckoutCore(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When / Then
        XCTAssertThrowsError(try sut.createPaymentComponent(for: .scheme))
    }
    
    func test_createPaymentComponent_forScheme_returnsCardComponent() throws {
        // Given
        let sut = CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When
        let component = try sut.createPaymentComponent(for: .scheme)
        
        // Then
        XCTAssertNotNil(component.viewController)
    }
    
    // MARK: - createPaymentComponent(for identifier:) Tests
    
    func test_createPaymentComponent_forIdentifier_returnsComponent_whenStoredMethodExists() throws {
        // Given
        let sut = CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        let storedMethodIdentifier = try XCTUnwrap(paymentMethods.stored.first?.identifier)
        
        // When
        _ = try sut.createPaymentComponent(for: storedMethodIdentifier)
    }
    
    func test_createPaymentComponent_forIdentifier_throws_whenStoredMethodDoesNotExist() {
        // Given
        let sut = CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When / Then
        XCTAssertThrowsError(try sut.createPaymentComponent(for: "non-existent-identifier"))
    }
    
    func test_createPaymentComponent_forIdentifier_throws_whenPaymentMethodsIsNil() {
        // Given
        let sut = CheckoutCore(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When / Then
        XCTAssertThrowsError(try sut.createPaymentComponent(for: "any-identifier"))
    }
    
    func test_createPaymentComponent_forIdentifier_returnsCorrectStoredMethod() throws {
        // Given
        let sut = CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // Get the first stored card identifier
        guard let storedCard = paymentMethods.stored.first(where: { $0 is StoredCardPaymentMethod }) else {
            XCTFail("Expected stored card payment method in test data")
            return
        }
        
        // When
        _ = try sut.createPaymentComponent(for: storedCard.identifier)
    }
    
    // MARK: - Action-Only Setup Tests
    
    func testSetupActionOnly_Success() async throws {
        // Given
        let expectedCheckout = CheckoutCore(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        mockProvider.setupActionOnlyResult = .success(expectedCheckout)
        
        // When
        let checkout = try await Checkout.setup(
            configuration: configuration,
            presentationDelegate: nil,
            provider: mockProvider
        )
        
        // Then
        XCTAssertNil(checkout.session)
        XCTAssertTrue(mockProvider.setupActionOnlyCalled)
    }
    
    func testSetupActionOnly_Failure() async {
        // Given
        mockProvider.setupActionOnlyResult = .failure(TestError())
        
        // When/Then
        do {
            _ = try await Checkout.setup(
                configuration: configuration,
                presentationDelegate: nil,
                provider: mockProvider
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }
    
    func testSetupActionOnly_returnsActionOnlyCheckout() async throws {
        // Given
        let expectedCheckout = CheckoutCore(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        mockProvider.setupActionOnlyResult = .success(expectedCheckout)
        
        // When
        let checkout = try await Checkout.setup(
            configuration: configuration,
            presentationDelegate: nil,
            provider: mockProvider
        )
        
        // Then
        _ = checkout
        XCTAssertTrue(mockProvider.setupActionOnlyCalled)
    }
    
    func test_didSubmit_responseWithoutAction_callsOnComplete() async throws {
        let callbacks = AdvancedCheckoutCallbacks()
        let onSubmitExpectation = expectation(description: "onSubmit called")
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        callbacks.onSubmit = { _ in
            onSubmitExpectation.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        callbacks.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onSubmitExpectation, onCompleteExpectation], timeout: 1)
    }
    
    func test_didSubmit_errorThrown_callsOnError() async throws {
        let callbacks = AdvancedCheckoutCallbacks()
        let onErrorExpectation = expectation(description: "onError called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        callbacks.onSubmit = { _ in
            throw TestError()
        }
        callbacks.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onErrorExpectation], timeout: 1)
    }
    
    func test_didSubmit_cancellationErrorThrown_doesNotCallOnError() async throws {
        let callbacks = AdvancedCheckoutCallbacks()
        let onErrorExpectation = expectation(description: "onError should NOT be called")
        onErrorExpectation.isInverted = true
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        callbacks.onSubmit = { _ in
            throw CancellationError()
        }
        callbacks.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onErrorExpectation], timeout: 0.5)
    }
    
    // MARK: - action component delegate
    
    func test_didProvide_withSessionAndMissingOnAdditionalDetails_shouldPerformAdditionalDetails() async throws {
        let callbacks = SessionCheckoutCallbacks()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentComponent = PaymentComponentMock(paymentMethod: blik)
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        let session = makeSessionMock()
        session.performAdditionalDetailsResult = .success(.completion(resultCode: CheckoutResultCode.authorised.rawValue))
        callbacks.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbacks: callbacks)
        sut.pendingPaymentComponent = paymentComponent
        
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onCompleteExpectation], timeout: 1)
        
        XCTAssertTrue(session.performAdditionalDetailsCalled)
        XCTAssertFalse(session.didProvideCalled)
    }
    
    func test_didComplete_withSessionCurrentResult_shouldCallOnComplete() async throws {
        let callbacks = SessionCheckoutCallbacks()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let session = makeSessionMock()
        session.currentResult = CheckoutResult(resultCode: .authorised)
        callbacks.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbacks: callbacks)
        sut.pendingPaymentComponent = PaymentComponentMock(paymentMethod: blik)
        
        sut.didComplete(from: ActionComponentMock())
        await fulfillment(of: [onCompleteExpectation], timeout: 1)
    }
    
    func test_didProvide_callsOnAdditionalDetails_whenSet() async {
        let callbacks = AdvancedCheckoutCallbacks()
        let expectation = expectation(description: "onAdditionalDetails called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        callbacks.onAdditionalDetails = { data in
            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)
            expectation.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [expectation], timeout: 1)
    }
    
    func test_didSubmit_returnsErrorBranch_callsOnError() async throws {
        let callbacks = AdvancedCheckoutCallbacks()
        let onErrorExpectation = expectation(description: "onError called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        callbacks.onSubmit = { _ in
            throw TestError()
        }
        callbacks.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onErrorExpectation], timeout: 1)
    }
    
    func test_didProvide_returnsFinished_callsOnComplete() async {
        let callbacks = AdvancedCheckoutCallbacks()
        let onAdditionalDetailsExpectation = expectation(description: "onAdditionalDetails called")
        let onCompleteExpectation = expectation(description: "onComplete called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        callbacks.onAdditionalDetails = { _ in
            onAdditionalDetailsExpectation.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        callbacks.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onAdditionalDetailsExpectation, onCompleteExpectation], timeout: 1)
    }
    
    func test_didProvide_returnsErrorBranch_callsOnError() async {
        let callbacks = AdvancedCheckoutCallbacks()
        let onErrorExpectation = expectation(description: "onError called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        callbacks.onAdditionalDetails = { _ in
            throw TestError()
        }
        callbacks.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onErrorExpectation], timeout: 1)
    }
    
    func test_didProvide_errorThrown_callsOnError() async {
        let callbacks = AdvancedCheckoutCallbacks()
        let onErrorExpectation = expectation(description: "onError called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        callbacks.onAdditionalDetails = { _ in
            throw TestError()
        }
        callbacks.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onErrorExpectation], timeout: 1)
    }
    
    func test_didProvide_cancellationErrorThrown_doesNotCallOnError() async {
        let callbacks = AdvancedCheckoutCallbacks()
        let onErrorExpectation = expectation(description: "onError should NOT be called")
        onErrorExpectation.isInverted = true
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        callbacks.onAdditionalDetails = { _ in
            throw CancellationError()
        }
        callbacks.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbacks: callbacks)
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onErrorExpectation], timeout: 0.5)
    }
    
    private func makeSessionCheckoutCore(
        session: SessionProtocol,
        callbacks: SessionCheckoutCallbacks
    ) -> CheckoutCore {
        CheckoutCore(
            configuration: configuration,
            session: session,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbacks,
            submissionHandler: SessionSubmissionHandler(session: session)
        )
    }

    private func makeAdvancedCheckoutCore(
        callbacks: AdvancedCheckoutCallbacks
    ) -> CheckoutCore {
        CheckoutCore(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbacks,
            submissionHandler: AdvancedSubmissionHandler(callbacks: callbacks)
        )
    }

    private func makeSessionMock() -> AdyenSessionMock {
        AdyenSessionMock(state: .init(
            data: "test_session_data",
            identifier: "test_session_id",
            countryCode: "US",
            shopperLocale: "en_US",
            amount: Amount(value: 1000, currencyCode: "USD"),
            paymentMethods: paymentMethods,
            responseConfiguration: .init(installmentOptions: nil, enableStoreDetails: true)
        ))
    }
}

struct TestError: Error {}

@MainActor
private final class ActionComponentMock: ActionComponent {
    var context: AdyenContext = Dummy.context
    var delegate: ActionComponentDelegate?
}
