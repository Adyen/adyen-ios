//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// TODO: Finalize all the parameters of the callbacks
// Move Action to core module?
// Add Resultcode enum
public typealias PaymentsResponseHandler = (_ resultCode: String, _ action: String) -> Void
public typealias SubmitHandler = (_ data: PaymentComponentData, _ handler: PaymentsResponseHandler?) -> Void
public typealias AdditionalDetailsHandler = (_ data: ActionComponentData, _ handler: PaymentsResponseHandler?) -> Void
// TODO: Have a checkout error object?
public typealias CheckoutErrorHandler = (_ error: Error) -> Void
public typealias CheckoutSuccessHandler = (_ resultCode: String) -> Void

/// Basic callbacks for all components.
package protocol CheckoutBaseCallbacks {
    
    var onSubmit: SubmitHandler? { get set }
    
    var onAdditionalDetails: AdditionalDetailsHandler? { get set }
    
    var onError: CheckoutErrorHandler? { get set }
    
    var onComplete: CheckoutSuccessHandler? { get set }
}

public extension CheckoutConfiguration {
    
    // TODO: Add function descriptions
    
    func onSubmit(_ onSubmit: @escaping SubmitHandler) -> Self {
        var copy = self
        copy.onSubmit = onSubmit
        return copy
    }
    
    func onAdditionalDetails(_ onAdditionalDetails: @escaping AdditionalDetailsHandler) -> Self {
        var copy = self
        copy.onAdditionalDetails = onAdditionalDetails
        return copy
    }
    
    func onError(_ onError: @escaping CheckoutErrorHandler) -> Self {
        var copy = self
        copy.onError = onError
        return copy
    }
    
    func onComplete(_ onComplete: @escaping CheckoutSuccessHandler) -> Self {
        var copy = self
        copy.onComplete = onComplete
        return copy
    }
    
    // add other callbacks that multiple components can use
    // balance check, order
}
