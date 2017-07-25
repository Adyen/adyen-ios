//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension Dictionary {
    
    mutating func formUnion(_ dictionary: [Key: Value]) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
    
    mutating func formUnion<S: Sequence>(_ sequence: S) where
        S.Iterator.Element == (Key, Value) {
        for (key, value) in sequence {
            self[key] = value
        }
    }
}

extension Dictionary where Key == NSAttributedStringKey, Value == NSObject {

    var stringAny: [String: Any] {
        let uniqueKeysWithValues: [(String, Any)] = map { ($0.key.rawValue, $0.value) }
        return [String: Any](uniqueKeysWithValues: uniqueKeysWithValues)
    }

}
