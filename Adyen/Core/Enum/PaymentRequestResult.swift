//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Result of a payment request.
public enum PaymentRequestResult {
    
    /// In case of success a `Payment` object will be returned.
    case payment(Payment)
    
    /// In case of failure an `Error` will be returned.
    case error(Error)
}
