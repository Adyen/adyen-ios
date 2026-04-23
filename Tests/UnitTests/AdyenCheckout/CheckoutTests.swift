//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenCheckout
@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenSession
@_spi(AdyenInternal) @testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenActions
import XCTest

@MainActor
final class CheckoutTests: XCTestCase {
    /// Sentinel used when the advanced (non-session) action flow has no server-provided
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
        
        let expectedCheckout = Checkout(
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
        XCTAssertTrue(checkout.session?.delegate === checkout)
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
        let expectedCheckout = Checkout(
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
    
    func test_didSubmit_callsOnSubmit_whenSet() async throws {
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
        
        configuration.onSubmit = { data in
            didCallSubmit = true
            XCTAssertEqual(data.paymentMethod.sdkData, paymentData.paymentMethod.sdkData)
            let details = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(details.type, blikDetails.type)
            XCTAssertEqual(details.blikCode, blikDetails.blikCode)
            expectation.fulfill()
            
            return .finished(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [expectation], timeout: 1)
        
        XCTAssertTrue(didCallSubmit)
    }
    
    // MARK: - createPaymentComponent(for type:) Tests
    
    func test_createPaymentComponent_forType_returnsComponent_whenPaymentMethodExists() {
        // Given
        let sut = Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When
        let component = sut.createPaymentComponent(for: .blik)
        
        // Then
        XCTAssertNotNil(component)
        XCTAssertNotNil(component?.viewController)
    }
    
    func test_createPaymentComponent_forType_returnsNil_whenPaymentMethodDoesNotExist() {
        // Given
        let sut = Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When
        let component = sut.createPaymentComponent(for: .ideal)
        
        // Then
        XCTAssertNil(component)
    }
    
    func test_createPaymentComponent_forType_returnsNil_whenPaymentMethodsIsNil() {
        // Given
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When
        let component = sut.createPaymentComponent(for: .scheme)
        
        // Then
        XCTAssertNil(component)
    }
    
    func test_createPaymentComponent_forScheme_returnsCardComponent() {
        // Given
        let sut = Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When
        let component = sut.createPaymentComponent(for: .scheme)
        
        // Then
        XCTAssertNotNil(component)
        XCTAssertNotNil(component?.viewController)
    }
    
    // MARK: - createPaymentComponent(for identifier:) Tests
    
    func test_createPaymentComponent_forIdentifier_returnsComponent_whenStoredMethodExists() throws {
        // Given
        let sut = Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        let storedMethodIdentifier = try XCTUnwrap(paymentMethods.stored.first?.identifier)
        
        // When
        let component = sut.createPaymentComponent(for: storedMethodIdentifier)
        
        // Then
        XCTAssertNotNil(component)
    }
    
    func test_createPaymentComponent_forIdentifier_returnsNil_whenStoredMethodDoesNotExist() {
        // Given
        let sut = Checkout(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When
        let component = sut.createPaymentComponent(for: "non-existent-identifier")
        
        // Then
        XCTAssertNil(component)
    }
    
    func test_createPaymentComponent_forIdentifier_returnsNil_whenPaymentMethodsIsNil() {
        // Given
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        
        // When
        let component = sut.createPaymentComponent(for: "any-identifier")
        
        // Then
        XCTAssertNil(component)
    }
    
    func test_createPaymentComponent_forIdentifier_returnsCorrectStoredMethod() {
        // Given
        let sut = Checkout(
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
        let component = sut.createPaymentComponent(for: storedCard.identifier)
        
        // Then
        XCTAssertNotNil(component)
    }
    
    // MARK: - Action-Only Setup Tests
    
    func testSetupActionOnly_Success() async throws {
        // Given
        let expectedCheckout = Checkout(
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
        XCTAssertNil(checkout.paymentMethods)
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
    
    func testSetupActionOnly_createPaymentComponent_returnsNil() async throws {
        // Given
        let expectedCheckout = Checkout(
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
        
        // Then - createPaymentComponent should return nil since no paymentMethods
        let component = checkout.createPaymentComponent(for: .scheme)
        XCTAssertNil(component)
    }
    
    func test_didSubmit_responseWithoutAction_callsOnComplete() async throws {
        let onSubmitExpectation = expectation(description: "onSubmit called")
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        configuration.onSubmit = { _ in
            onSubmitExpectation.fulfill()
            return .finished(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        configuration.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onSubmitExpectation, onCompleteExpectation], timeout: 1)
    }
    
    func test_didSubmit_errorThrown_callsOnError() async throws {
        let onErrorExpectation = expectation(description: "onError called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        configuration.onSubmit = { _ in
            throw TestError()
        }
        configuration.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onErrorExpectation], timeout: 1)
    }
    
    func test_didSubmit_cancellationErrorThrown_doesNotCallOnError() async throws {
        let onErrorExpectation = expectation(description: "onError should NOT be called")
        onErrorExpectation.isInverted = true
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        configuration.onSubmit = { _ in
            throw CancellationError()
        }
        configuration.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onErrorExpectation], timeout: 0.5)
    }
    
    // MARK: - action component delegate
    
    func test_didProvide_callsOnAdditionalDetails_whenSet() async {
        let expectation = expectation(description: "onAdditionalDetails called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        configuration.onAdditionalDetails = { data in
            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)
            expectation.fulfill()
            return .finished(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [expectation], timeout: 1)
    }
    
    func test_didSubmit_returnsErrorBranch_callsOnError() async throws {
        let onErrorExpectation = expectation(description: "onError called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        configuration.onSubmit = { _ in
            .error(TestError())
        }
        configuration.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onErrorExpectation], timeout: 1)
    }
    
    func test_didProvide_returnsFinished_callsOnComplete() async {
        let onAdditionalDetailsExpectation = expectation(description: "onAdditionalDetails called")
        let onCompleteExpectation = expectation(description: "onComplete called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        configuration.onAdditionalDetails = { _ in
            onAdditionalDetailsExpectation.fulfill()
            return .finished(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        configuration.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onAdditionalDetailsExpectation, onCompleteExpectation], timeout: 1)
    }
    
    func test_didProvide_returnsErrorBranch_callsOnError() async {
        let onErrorExpectation = expectation(description: "onError called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        configuration.onAdditionalDetails = { _ in
            .error(TestError())
        }
        configuration.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onErrorExpectation], timeout: 1)
    }
    
    func test_didProvide_errorThrown_callsOnError() async {
        let onErrorExpectation = expectation(description: "onError called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        configuration.onAdditionalDetails = { _ in
            throw TestError()
        }
        configuration.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onErrorExpectation], timeout: 1)
    }
    
    func test_didProvide_cancellationErrorThrown_doesNotCallOnError() async {
        let onErrorExpectation = expectation(description: "onError should NOT be called")
        onErrorExpectation.isInverted = true
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        configuration.onAdditionalDetails = { _ in
            throw CancellationError()
        }
        configuration.onError = { _ in
            onErrorExpectation.fulfill()
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onErrorExpectation], timeout: 0.5)
    }
}

struct TestError: Error {}

@MainActor
private final class ActionComponentMock: ActionComponent {
    var context: AdyenContext = Dummy.context
    var delegate: ActionComponentDelegate?
}
