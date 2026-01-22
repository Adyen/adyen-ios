//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenActions
import AdyenComponents
import AdyenDropIn
import AdyenSession

class SessionDelegateMock: AdyenSessionDelegate {
    
    var onDidComplete: ((CheckoutResult, Component, Session) -> Void)?
    var onDidFail: ((Error, Component, Session) -> Void)?
    var onDidOpenExternalApplication: (() -> Void)?
    
    func didComplete(with result: CheckoutResult, component: Component, session: Session) {
        onDidComplete?(result, component, session)
    }
    
    func didFail(with error: Error, from component: Component, session: Session) {
        onDidFail?(error, component, session)
    }
    
    func didOpenExternalApplication(component: ActionComponent, session: Session) {
        onDidOpenExternalApplication?()
    }
}
