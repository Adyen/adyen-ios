//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Array where Element == PaymentDetail {
    /// Returns a dictionary of the filled payment details.
    internal var serialized: [String: Any] {
        let elements = compactMap { paymentDetail -> (String, Any)? in
            guard let value = paymentDetail.value else { return nil }
            
            return (paymentDetail.key, value)
        }
        
        return Dictionary(uniqueKeysWithValues: elements)
    }
    
    /// Returns the payment detail for the given key.
    ///
    /// - Parameter key: The key to retrieve the payment detail for.
    public subscript(key: String) -> PaymentDetail? {
        get {
            return first { $0.key == key }
        }
        
        set {
            if let existingIndex = index(where: { $0.key == key }) {
                if let newValue = newValue {
                    self[existingIndex] = newValue
                } else {
                    remove(at: existingIndex)
                }
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
}

public extension Array where Element == PaymentDetail {
    /// The payment detail for Store Details
    public var storeDetails: PaymentDetail? {
        get {
            return self[storeDetailsKey]
        }
        
        set {
            self[storeDetailsKey] = newValue
        }
    }
}

private let storeDetailsKey = "storeDetails"
