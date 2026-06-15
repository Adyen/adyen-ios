//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenSession

public final class AdyenSessionMock: SessionProtocol {
    public var state: Session.State
    public var presentationDelegate: PresentationDelegate?
    public var showRemovePaymentMethodButton = false

    var didSubmitCalled = false
    var didProvideCalled = false
    var performSubmitCalled = false
    var performAdditionalDetailsCalled = false
    var performBalanceCheckCalled = false
    var requestOrderCalled = false
    var cancelOrderCalled = false
    var disableStoredPaymentMethodCalled = false
    var performSubmitResult: Result<SubmitResult, Error>?
    var performAdditionalDetailsResult: Result<AdditionalDetailsResult, Error>?
    var performBalanceCheckResult: Result<Balance, Error>?
    var requestOrderResult: Result<PartialPaymentOrder, Error>?

    internal init(
        state: Session.State,
        presentationDelegate: PresentationDelegate? = nil
    ) {
        self.state = state
        self.presentationDelegate = presentationDelegate
    }
    
    var refreshSessionStateCalled = false
    var refreshSessionStateData: String?
    
    public func refreshSessionState(with sessionData: String) async throws {
        refreshSessionStateCalled = true
        refreshSessionStateData = sessionData
    }
    
    public func performSubmit(_ data: PaymentComponentData) async throws -> SubmitResult {
        performSubmitCalled = true
        guard let performSubmitResult else { throw AdyenSessionMockError.missingResult }
        return try performSubmitResult.get()
    }
    
    public func performAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult {
        performAdditionalDetailsCalled = true
        guard let performAdditionalDetailsResult else { throw AdyenSessionMockError.missingResult }
        return try performAdditionalDetailsResult.get()
    }
    
    public func performBalanceCheck(with data: PaymentComponentData) async throws -> Balance {
        performBalanceCheckCalled = true
        guard let performBalanceCheckResult else { throw AdyenSessionMockError.missingResult }
        return try performBalanceCheckResult.get()
    }
    
    public func requestOrder() async throws -> PartialPaymentOrder {
        requestOrderCalled = true
        guard let requestOrderResult else { throw AdyenSessionMockError.missingResult }
        return try requestOrderResult.get()
    }
    
    public func cancelOrder(_ order: PartialPaymentOrder) async {
        cancelOrderCalled = true
    }
    
    public func disable(storedPaymentMethod: StoredPaymentMethod) async throws {
        disableStoredPaymentMethodCalled = true
    }
    
}

private enum AdyenSessionMockError: Error {
    case missingResult
}
