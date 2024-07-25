//
// Copyright (c) 2024 Adyen N.V.
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

@_spi(AdyenInternal)
public extension Encodable {
    
    /// Creates a [String: String] representation of the encodable type if possible.
    func toStringDictionary() -> [String: String]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        return jsonDictionary
    }
}
