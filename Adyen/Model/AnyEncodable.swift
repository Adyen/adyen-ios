//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
private extension Encodable {
    
    /// :nodoc:
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
    
}

/// Provides a concrete encodable object to easily encode any `Encodable` conforming object, without exposing the concrete type.
/// :nodoc:
public struct AnyEncodable: Encodable {
    
    private let value: Encodable
    
    internal init(value: Encodable) {
        self.value = value
    }
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
    
}
