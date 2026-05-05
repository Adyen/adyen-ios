//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import AdyenNetworking

package protocol SessionProtocol: AnyObject {
    var state: Session.State { get }
    var delegate: SessionDelegate? { get set }
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
