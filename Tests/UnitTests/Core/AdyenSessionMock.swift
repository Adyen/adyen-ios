//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenSession
@_spi(AdyenInternal) @testable import Adyen

public final class AdyenSessionMock: AdyenSessionProtocol {
    public var state: AdyenSession.State
    public var delegate: AdyenSessionDelegate?
    public var presentationDelegate: PresentationDelegate?

    var didSubmitCalled = false
    var didProvideCalled = false

    internal init(
        state: AdyenSession.State,
        delegate: AdyenSessionDelegate? = nil,
        presentationDelegate: PresentationDelegate? = nil
    ) {
        self.state = state
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
