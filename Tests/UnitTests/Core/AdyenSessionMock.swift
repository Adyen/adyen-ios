//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenSession
@_spi(AdyenInternal) @testable import Adyen

public final class AdyenSessionMock: AdyenSessionProtocol {
    public var sessionContext: AdyenSession.Context
    public var delegate: AdyenSessionDelegate?
    public var presentationDelegate: PresentationDelegate?

    var didSubmitCalled = false
    var didProvideCalled = false

    internal init(
        sessionContext: AdyenSession.Context,
        delegate: AdyenSessionDelegate? = nil,
        presentationDelegate: PresentationDelegate? = nil
    ) {
        self.sessionContext = sessionContext
        self.delegate = delegate
        self.presentationDelegate = presentationDelegate
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
