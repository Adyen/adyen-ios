//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains details supplied by a component. These details are used to initiate or complete a payment.
public protocol Details: Encodable {
    
    /// An encoded representation of the details.
    var dictionaryRepresentation: [String: Any] { get }
    
}

/// Contains the payment details entered by the user to complete payment with chosen payment method.
public protocol PaymentMethodDetails: Details {}

/// Contains additional details that were retrieved to complete a payment.
public protocol AdditionalDetails: Details {}

/// :nodoc:
public extension Details {
    
    /// An encoded representation of the details.
    var dictionaryRepresentation: [String: Any] {
        do {
            let data = try Coder.encode(self) as Data
            let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            return dictionary ?? [:]
        } catch {
            return [:]
        }
    }
    
}
