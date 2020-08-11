//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An error that reflects the payment status.
public enum PaymentError: Swift.Error {
    
    /// Indicates that the payment has been canceled.
    case cancelled
    
    /// Indicates that an error occured during the payment processing.
    case error
    
    /// Indicates that the payment was refused.
    case refused
}
