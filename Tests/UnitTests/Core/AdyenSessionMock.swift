//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenSession
@_spi(AdyenInternal) @testable import Adyen

public final class AdyenSessionMock: SessionProtocol {
    public var state: Session.State
    public var currentResult: CheckoutResult?
    public var delegate: SessionDelegate?
    public var presentationDelegate: PresentationDelegate?

    var didSubmitCalled = false
    var didProvideCalled = false
    var performSubmitCalled = false
    var performAdditionalDetailsCalled = false
    var performSubmitResult: Result<SubmitResult, Error>?
    var performAdditionalDetailsResult: Result<AdditionalDetailsResult, Error>?

    internal init(
        state: Session.State,
        delegate: SessionDelegate? = nil,
        presentationDelegate: PresentationDelegate? = nil
    ) {
        self.state = state
        self.delegate = delegate
        self.presentationDelegate = presentationDelegate
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
    
    public func didSubmit(
        _ paymentComponentData: PaymentComponentData,
        from component: any PaymentComponent,
        dropInComponent: (any AnyDropInComponent)?
    ) {
        didSubmitCalled = true
    }
    
    public func didProvide(
        _ actionComponentData: ActionComponentData,
        from component: any ActionComponent,
        dropInComponent: (any AnyDropInComponent)?
    ) {
        didProvideCalled = true
    }
}

private enum AdyenSessionMockError: Error {
    case missingResult
}
