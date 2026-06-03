//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
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

    func test_actionHandlingComponent_withCheckoutLocalizationProvider_shouldResolveLocalizationParametersForActionAndAuthenticationConfigurations() throws {
        // Given
        let provider = CheckoutLocalizationProviderMock(values: [
            .awaitLoading: "Await custom",
            .cardNumber: "Card number"
        ])
        configuration = configuration.localizationProvider(provider)
        let sut = makeActionOnlyCheckoutCore()

        // When
        let actionComponent = try XCTUnwrap(sut.actionHandlingComponent as? CheckoutActionComponent)

        // Then
        let actionLocalizationParameters = try XCTUnwrap(actionComponent.configuration.localizationParameters)
        let authenticationLocalizationParameters = try XCTUnwrap(actionComponent.configuration.authentication.localizationParameters)
        XCTAssertEqual(localizedString(.awaitWaitForConfirmation, actionLocalizationParameters), "Await custom")
        XCTAssertEqual(localizedString(.cardNumberItemTitle, authenticationLocalizationParameters), "Card number")
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
        
        let expectedCheckout = makeSessionCheckoutCore(session: expectedSession)
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
        let expectedCheckout = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)
        
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
        let callbackStore = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        let session = makeSessionMock()
        session.performSubmitResult = .success(.completion(resultCode: CheckoutResultCode.authorised.rawValue))
        callbackStore.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbackStore: callbackStore)
        
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onCompleteExpectation], timeout: 1)
        
        XCTAssertTrue(session.performSubmitCalled)
        XCTAssertFalse(session.didSubmitCalled)
    }
    
    func test_didSubmit_withSessionPerformSubmitError_shouldCallOnError() async throws {
        let callbackStore = SessionCheckoutCallbackStore()
        let onErrorExpectation = expectation(description: "onError called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        let session = makeSessionMock()
        session.performSubmitResult = .failure(TestError())
        callbackStore.onError = { _ in
            onErrorExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbackStore: callbackStore)
        
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onErrorExpectation], timeout: 1)
        
        XCTAssertTrue(session.performSubmitCalled)
        XCTAssertFalse(session.didSubmitCalled)
    }
    
    // MARK: - onBeforeSubmit
    
    func test_didSubmit_withNoOnBeforeSubmit_shouldPerformSubmitDirectly() async throws {
        let callbackStore = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        let session = makeSessionMock()
        session.performSubmitResult = .success(.completion(resultCode: CheckoutResultCode.authorised.rawValue))
        callbackStore.onComplete = { _ in
            onCompleteExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbackStore: callbackStore)
        
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onCompleteExpectation], timeout: 1)
        
        XCTAssertTrue(session.performSubmitCalled)
        XCTAssertFalse(session.refreshSessionStateCalled)
    }
    
    func test_didSubmit_withOnBeforeSubmitProceed_shouldApplyModifiedData() async throws {
        let callbackStore = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        let session = makeSessionMock()
        session.performSubmitResult = .success(.completion(resultCode: CheckoutResultCode.authorised.rawValue))
        
        let modifiedName = ShopperName(firstName: "Modified", lastName: "Name")
        callbackStore.onBeforeSubmit = { data in
            let modified = data
                .replacing(shopperName: modifiedName)
                .replacing(shopperEmail: "modified@test.com")
            return .proceed(data: modified, sessionData: nil)
        }
        callbackStore.onComplete = { _ in
            onCompleteExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbackStore: callbackStore)
        
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onCompleteExpectation], timeout: 1)
        
        XCTAssertTrue(session.performSubmitCalled)
        XCTAssertFalse(session.refreshSessionStateCalled)
    }
    
    func test_didSubmit_withOnBeforeSubmitProceedAndSessionData_shouldRefreshSession() async throws {
        let callbackStore = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        let session = makeSessionMock()
        session.performSubmitResult = .success(.completion(resultCode: CheckoutResultCode.authorised.rawValue))
        
        callbackStore.onBeforeSubmit = { data in
            .proceed(data: data, sessionData: "patched_session_data")
        }
        callbackStore.onComplete = { _ in
            onCompleteExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbackStore: callbackStore)
        
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onCompleteExpectation], timeout: 1)
        
        XCTAssertTrue(session.refreshSessionStateCalled)
        XCTAssertEqual(session.refreshSessionStateData, "patched_session_data")
        XCTAssertTrue(session.performSubmitCalled)
    }
    
    func test_didSubmit_withOnBeforeSubmitAbort_shouldStopLoadingAndNotCallOnError() async throws {
        let callbackStore = SessionCheckoutCallbackStore()
        let onErrorExpectation = expectation(description: "onError should NOT be called")
        onErrorExpectation.isInverted = true
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        let session = makeSessionMock()
        
        callbackStore.onBeforeSubmit = { _ in
            .abort
        }
        callbackStore.onError = { _ in
            onErrorExpectation.fulfill()
        }
        let component = PresentableComponentMock(paymentMethod: blik, viewController: UIViewController())
        let sut = makeSessionCheckoutCore(session: session, callbackStore: callbackStore)
        
        sut.didSubmit(paymentData, from: component)
        await fulfillment(of: [onErrorExpectation], timeout: 0.5)
        
        XCTAssertTrue(component.stopLoadingCalled)
        XCTAssertFalse(session.performSubmitCalled)
    }
    
    func test_paymentComponentData_replacingBeforeSubmitData_shouldOverrideShopperFields() throws {
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let original = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        XCTAssertNil(original.shopperName)
        XCTAssertNil(original.emailAddress)
        XCTAssertNil(original.billingAddress)
        XCTAssertNil(original.deliveryAddress)
        
        let overrides = BeforeSubmitData(
            billingAddress: nil,
            deliveryAddress: nil,
            shopperName: nil,
            shopperEmail: nil
        )
        .replacing(billingAddress: PostalAddress(city: "Amsterdam", country: "NL"))
        .replacing(deliveryAddress: PostalAddress(city: "Berlin", country: "DE"))
        .replacing(shopperName: ShopperName(firstName: "John", lastName: "Doe"))
        .replacing(shopperEmail: "john@example.com")
        
        let updated = original.replacing(beforeSubmitData: overrides)
        
        XCTAssertEqual(updated.shopperName, ShopperName(firstName: "John", lastName: "Doe"))
        XCTAssertEqual(updated.emailAddress, "john@example.com")
        XCTAssertEqual(updated.billingAddress?.city, "Amsterdam")
        XCTAssertEqual(updated.deliveryAddress?.city, "Berlin")
    }
    
    func test_didSubmit_callsOnSubmit_whenSet() async throws {
        let callbackStore = AdvancedCheckoutCallbackStore()
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
        
        callbackStore.onSubmit = { data in
            didCallSubmit = true
            XCTAssertEqual(data.paymentMethod.sdkData, paymentData.paymentMethod.sdkData)
            let details = data.paymentMethod as! BLIKDetails
            XCTAssertEqual(details.type, blikDetails.type)
            XCTAssertEqual(details.blikCode, blikDetails.blikCode)
            expectation.fulfill()
            
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        
        let sut = makeAdvancedCheckoutCore(callbackStore: callbackStore)
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [expectation], timeout: 1)
        
        XCTAssertTrue(didCallSubmit)
    }
    
    // MARK: - createPaymentComponent(for type:) Tests
    
    func test_createPaymentComponent_forType_returnsComponent_whenPaymentMethodExists() throws {
        // Given
        let sut = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)
        
        // When
        let component = try sut.createPaymentComponent(for: .blik)
        
        // Then
        XCTAssertNotNil(component.viewController)
    }
    
    func test_createPaymentComponent_forType_throws_whenPaymentMethodDoesNotExist() {
        // Given
        let sut = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)
        
        // When / Then
        XCTAssertThrowsError(try sut.createPaymentComponent(for: .ideal))
    }
    
    func test_createPaymentComponent_forType_throws_whenPaymentMethodsIsNil() {
        // Given
        let sut = makeAdvancedCheckoutCore()
        
        // When / Then
        XCTAssertThrowsError(try sut.createPaymentComponent(for: .scheme))
    }
    
    func test_createPaymentComponent_forScheme_returnsCardComponent() throws {
        // Given
        let sut = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)
        
        // When
        let component = try sut.createPaymentComponent(for: .scheme)
        
        // Then
        XCTAssertNotNil(component.viewController)
    }
    
    // MARK: - createPaymentComponent(for identifier:) Tests
    
    func test_createPaymentComponent_forIdentifier_returnsComponent_whenStoredMethodExists() throws {
        // Given
        let sut = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)
        let storedMethodIdentifier = try XCTUnwrap(paymentMethods.stored.first?.identifier)
        
        // When
        _ = try sut.createPaymentComponent(for: storedMethodIdentifier)
    }
    
    func test_createPaymentComponent_forIdentifier_throws_whenStoredMethodDoesNotExist() {
        // Given
        let sut = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)
        
        // When / Then
        XCTAssertThrowsError(try sut.createPaymentComponent(for: "non-existent-identifier"))
    }
    
    func test_createPaymentComponent_forIdentifier_throws_whenPaymentMethodsIsNil() {
        // Given
        let sut = makeAdvancedCheckoutCore()
        
        // When / Then
        XCTAssertThrowsError(try sut.createPaymentComponent(for: "any-identifier"))
    }
    
    func test_createPaymentComponent_forIdentifier_returnsCorrectStoredMethod() throws {
        // Given
        let sut = makeAdvancedCheckoutCore(paymentMethods: paymentMethods)
        
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
        let expectedCheckout = makeActionOnlyCheckoutCore()
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
        let expectedCheckout = makeActionOnlyCheckoutCore()
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
        let callbackStore = AdvancedCheckoutCallbackStore()
        let onSubmitExpectation = expectation(description: "onSubmit called")
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )
        
        callbackStore.onSubmit = { _ in
            onSubmitExpectation.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        callbackStore.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbackStore: callbackStore)
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onSubmitExpectation, onCompleteExpectation], timeout: 1)
    }
    
    // MARK: - action component delegate
    
    func test_didProvide_withSessionAndMissingOnAdditionalDetails_shouldPerformAdditionalDetails() async throws {
        let callbackStore = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentComponent = PaymentComponentMock(paymentMethod: blik)
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        let session = makeSessionMock()
        session.performAdditionalDetailsResult = .success(.completion(resultCode: CheckoutResultCode.authorised.rawValue))
        callbackStore.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbackStore: callbackStore)
        sut.pendingPaymentComponent = paymentComponent
        
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onCompleteExpectation], timeout: 1)
        
        XCTAssertTrue(session.performAdditionalDetailsCalled)
        XCTAssertFalse(session.didProvideCalled)
    }
    
    func test_didComplete_withSessionCurrentResult_shouldCallOnComplete() async throws {
        let callbackStore = SessionCheckoutCallbackStore()
        let onCompleteExpectation = expectation(description: "onComplete called")
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let session = makeSessionMock()
        session.currentResult = CheckoutResult(resultCode: .authorised)
        callbackStore.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        let sut = makeSessionCheckoutCore(session: session, callbackStore: callbackStore)
        sut.pendingPaymentComponent = PaymentComponentMock(paymentMethod: blik)
        
        sut.didComplete(from: ActionComponentMock())
        await fulfillment(of: [onCompleteExpectation], timeout: 1)
    }
    
    func test_didProvide_callsOnAdditionalDetails_whenSet() async {
        let callbackStore = AdvancedCheckoutCallbackStore()
        let expectation = expectation(description: "onAdditionalDetails called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        callbackStore.onAdditionalDetails = { data in
            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)
            expectation.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        
        let sut = makeAdvancedCheckoutCore(callbackStore: callbackStore)
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [expectation], timeout: 1)
    }
    
    func test_didProvide_actionOnlyCallsOnAdditionalDetails_whenSet() async {
        let callbackStore = ActionOnlyCheckoutCallbackStore()
        let expectation = expectation(description: "onAdditionalDetails called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )

        callbackStore.onAdditionalDetails = { data in
            XCTAssertEqual(data.paymentData, "data")
            XCTAssertNotNil(data.details as? AwaitActionDetails)
            expectation.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }

        let sut = makeActionOnlyCheckoutCore(callbackStore: callbackStore)
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [expectation], timeout: 1)
    }
    
    func test_didProvide_returnsFinished_callsOnComplete() async {
        let callbackStore = AdvancedCheckoutCallbackStore()
        let onAdditionalDetailsExpectation = expectation(description: "onAdditionalDetails called")
        let onCompleteExpectation = expectation(description: "onComplete called")
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )
        
        callbackStore.onAdditionalDetails = { _ in
            onAdditionalDetailsExpectation.fulfill()
            return .completion(resultCode: CheckoutResultCode.authorised.rawValue)
        }
        callbackStore.onComplete = { result in
            XCTAssertEqual(result.resultCode, .authorised)
            onCompleteExpectation.fulfill()
        }
        
        let sut = makeAdvancedCheckoutCore(callbackStore: callbackStore)
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onAdditionalDetailsExpectation, onCompleteExpectation], timeout: 1)
    }
    
    func test_didSubmit_withErrorResultCode_callsOnComplete() async throws {
        let callbackStore = AdvancedCheckoutCallbackStore()
        let onSubmitExpectation = expectation(description: "onSubmit called")
        let onCompleteExpectation = expectation(description: "onComplete called")
        var onErrorCalled = false
        let blik = try XCTUnwrap(paymentMethods.paymentMethod(ofType: BLIKPaymentMethod.self))
        let paymentData = PaymentComponentData(
            paymentMethodDetails: BLIKDetails(paymentMethod: blik, blikCode: "code"),
            amount: nil,
            order: nil
        )

        callbackStore.onSubmit = { _ in
            onSubmitExpectation.fulfill()
            return .completion(resultCode: CheckoutResultCode.refused.rawValue)
        }
        callbackStore.onComplete = { result in
            XCTAssertEqual(result.resultCode, .refused)
            onCompleteExpectation.fulfill()
        }
        callbackStore.onError = { _ in onErrorCalled = true }

        let sut = makeAdvancedCheckoutCore(callbackStore: callbackStore)
        sut.didSubmit(paymentData, from: PaymentComponentMock(paymentMethod: blik))
        await fulfillment(of: [onSubmitExpectation, onCompleteExpectation], timeout: 1)
        XCTAssertFalse(onErrorCalled)
    }

    func test_didProvide_withErrorResultCode_callsOnComplete() async {
        let callbackStore = AdvancedCheckoutCallbackStore()
        let onAdditionalDetailsExpectation = expectation(description: "onAdditionalDetails called")
        let onCompleteExpectation = expectation(description: "onComplete called")
        var onErrorCalled = false
        let actionData = ActionComponentData(
            details: AwaitActionDetails(payload: "payload"),
            paymentData: "data"
        )

        callbackStore.onAdditionalDetails = { _ in
            onAdditionalDetailsExpectation.fulfill()
            return .completion(resultCode: CheckoutResultCode.refused.rawValue)
        }
        callbackStore.onComplete = { result in
            XCTAssertEqual(result.resultCode, .refused)
            onCompleteExpectation.fulfill()
        }
        callbackStore.onError = { _ in onErrorCalled = true }

        let sut = makeAdvancedCheckoutCore(callbackStore: callbackStore)
        sut.didProvide(actionData, from: ActionComponentMock())
        await fulfillment(of: [onAdditionalDetailsExpectation, onCompleteExpectation], timeout: 1)
        XCTAssertFalse(onErrorCalled)
    }

    private func makeSessionCheckoutCore(
        session: SessionProtocol,
        callbackStore: SessionCheckoutCallbackStore = SessionCheckoutCallbackStore()
    ) -> CheckoutCore {
        CheckoutCore(
            configuration: configuration,
            session: session,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbackStore,
            callbackHandler: BeforeSubmitCallbackHandler(
                handler: SessionCallbackHandler(session: session),
                session: session,
                callbackStore: callbackStore
            )
        )
    }

    private func makeAdvancedCheckoutCore(
        callbackStore: AdvancedCheckoutCallbackStore = AdvancedCheckoutCallbackStore(),
        paymentMethods: PaymentMethods? = nil
    ) -> CheckoutCore {
        CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbackStore,
            callbackHandler: AdvancedCallbackHandler(callbackStore: callbackStore)
        )
    }

    private func makeActionOnlyCheckoutCore(
        callbackStore: ActionOnlyCheckoutCallbackStore = ActionOnlyCheckoutCallbackStore()
    ) -> CheckoutCore {
        CheckoutCore(
            configuration: configuration,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbackStore,
            callbackHandler: ActionOnlyCallbackHandler(callbackStore: callbackStore)
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

private final class CheckoutLocalizationProviderMock: CheckoutLocalizationProvider {

    private let values: [CheckoutLocalizationKey: String]

    init(values: [CheckoutLocalizationKey: String]) {
        self.values = values
    }

    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        values[key]
    }
}
