//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import AdyenNetworking

package protocol SessionProtocol: AnyObject {
    var state: Session.State { get }
    var currentResult: CheckoutResult? { get }
    var delegate: SessionDelegate? { get set }
    var presentationDelegate: PresentationDelegate? { get set }
    
    @MainActor
    func performSubmit(_ data: PaymentComponentData) async throws -> SubmitResult
    
    @MainActor
    func performAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult
    
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
