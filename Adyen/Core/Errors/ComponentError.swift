//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An error that occurred during the use of a component.
public enum ComponentError: Error {
    /// Indicates the component was cancelled by the user.
    case cancelled
    
    /// Indicates the payment method is not supported by the SDK.
    case paymentMethodNotSupported
    
}
