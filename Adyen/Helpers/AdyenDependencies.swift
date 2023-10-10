//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides access to injected dependencies.
public struct AdyenDependencyValues {
    
    internal static var current = AdyenDependencyValues()
    
    /// A static subscript for updating the `currentValue` of `InjectionKey` instances.
    public static subscript<K>(key: K.Type) -> K.Value where K: AdyenDependencyKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }
    
    /// A static subscript accessor for updating and references dependencies directly.
    public static subscript<T>(_ keyPath: WritableKeyPath<AdyenDependencyValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

@propertyWrapper
public struct AdyenDependency<T> {
    private let keyPath: WritableKeyPath<AdyenDependencyValues, T>
    public var wrappedValue: T {
        get { AdyenDependencyValues[keyPath] }
        set { AdyenDependencyValues[keyPath] = newValue }
    }
    
    public init(_ keyPath: WritableKeyPath<AdyenDependencyValues, T>) {
        self.keyPath = keyPath
    }
}

public protocol AdyenDependencyKey {

    associatedtype Value

    static var currentValue: Self.Value { get set }
}
