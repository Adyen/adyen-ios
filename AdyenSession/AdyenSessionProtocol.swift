//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import AdyenNetworking

package protocol AdyenSessionProtocol: AnyObject {
    var state: AdyenSession.State { get }
    var delegate: AdyenSessionDelegate? { get set }
    var presentationDelegate: PresentationDelegate? { get set }
    
    func didSubmit(
        _ paymentComponentData: PaymentComponentData,
        from component: PaymentComponent,
        dropInComponent: AnyDropInComponent?
    )
    
    func didProvide(
        _ actionComponentData: ActionComponentData,
        from component: ActionComponent,
        dropInComponent: AnyDropInComponent?
    )
}
