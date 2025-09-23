//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

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
