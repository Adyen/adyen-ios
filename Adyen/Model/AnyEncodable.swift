//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

private extension Encodable {
    
    func encode(to container: inout SingleValueEncodingContainer) throws {
        try container.encode(self)
    }
    
}

/// Provides an encodable object without exposing the concrete type.
public protocol OpaqueEncodable: Encodable {

    /// Provides a concrete and opaque encodable object.
    var encodable: AnyEncodable { get }
}

/// Provides an encodable object without exposing the concrete type.
public extension OpaqueEncodable {

    /// Provides an encodable object without exposing the concrete type.
    var encodable: AnyEncodable {
        AnyEncodable(value: self)
    }
}

/// Provides a concrete encodable object to easily encode any `Encodable` conforming object, without exposing the concrete type.
public struct AnyEncodable: Encodable {
    
    private let value: Encodable

    internal init(value: Encodable) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try value.encode(to: &container)
    }
    
}
