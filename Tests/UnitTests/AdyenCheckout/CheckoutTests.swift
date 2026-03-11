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

final class CheckoutTests: XCTestCase {
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

    @MainActor func testSetupWithSession_Success() async throws {
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

    @MainActor func testSetupWithSession_Failure() async {
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

    @MainActor func testSetupWithPaymentMethods_Success() async throws {
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

    @MainActor func testSetupWithPaymentMethods_Failure() async {
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
    
    @MainActor func testSetupSessionProtocolCall() async {
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
    
    @MainActor func test_didSubmit_callsOnSubmit_whenSet() throws {
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
        
        configuration.onSubmit = { data, completion in
            didCallSubmit = true
            XCTAssertEqual(data.paymentMethod.sdkData, paymentData.paymentMethod.sdkData)
            let details = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(details.type, blikDetails.type)
            XCTAssertEqual(details.blikCode, blikDetails.blikCode)
            expectation.fulfill()
            
            completion?(CheckoutPaymentsResponse(resultCode: .authorised))
        }
        
        let sut = Checkout(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil
        )
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(didCallSubmit)
    }
    
    // MARK: - createPaymentComponent(for type:) Tests
    
    @MainActor func test_createPaymentComponent_forType_returnsComponent_whenPaymentMethodExists() {
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
    
    @MainActor func test_createPaymentComponent_forType_returnsNil_whenPaymentMethodDoesNotExist() {
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
    
    @MainActor func test_createPaymentComponent_forType_returnsNil_whenPaymentMethodsIsNil() {
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
    
    @MainActor func test_createPaymentComponent_forScheme_returnsCardComponent() {
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
    
    @MainActor func test_createPaymentComponent_forIdentifier_returnsComponent_whenStoredMethodExists() throws {
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
    
    @MainActor func test_createPaymentComponent_forIdentifier_returnsNil_whenStoredMethodDoesNotExist() {
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
    
    @MainActor func test_createPaymentComponent_forIdentifier_returnsNil_whenPaymentMethodsIsNil() {
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
    
    @MainActor func test_createPaymentComponent_forIdentifier_returnsCorrectStoredMethod() {
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
    
    @MainActor func testSetupActionOnly_Success() async throws {
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
    
    @MainActor func testSetupActionOnly_Failure() async {
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
    
    @MainActor func testSetupActionOnly_createPaymentComponent_returnsNil() async throws {
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
    
}

struct TestError: Error {}
