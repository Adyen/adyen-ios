//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

///Payment statuses.
public enum PaymentStatus: String {
    
    /// Payment pending.
    case received
    
    /// Payment authorised.
    case authorised
    
    /// Payment error.
    case error
    
    /// Payment refused.
    case refused
    
    /// Payment cancelled.
    case cancelled
}
