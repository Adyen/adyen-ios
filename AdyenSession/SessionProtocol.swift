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
    
    var showRemovePaymentMethodButton: Bool { get }
    
    func performSubmit(_ data: PaymentComponentData) async throws -> SubmitResult
    
    func performAdditionalDetails(_ data: ActionComponentData) async throws -> AdditionalDetailsResult
    
    func performBalanceCheck(with data: PaymentComponentData) async throws -> Balance
    
    func requestOrder() async throws -> PartialPaymentOrder
    
    func cancelOrder(_ order: PartialPaymentOrder) async
    
    func disable(storedPaymentMethod: StoredPaymentMethod) async throws
    
}
