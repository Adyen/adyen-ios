//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides access to injected dependencies.
@_documentation(visibility: internal)
public struct AdyenDependencyValues {
    
    /// The currently injected values
    fileprivate static var current = AdyenDependencyValues()
    
    /// Stores the testValues during ``runTestWithValues``
    private var storage: [ObjectIdentifier: Any] = [:]
    
    /// A subscript for updating the `currentValue` of `AdyenDependencyKey` instances.
    public subscript<K>(key: K.Type) -> K.Value where K: AdyenDependencyKey {
        get {
            (storage[ObjectIdentifier(key)] as? K.Value) ?? key.liveValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
    
    /// A static subscript accessor for updating and references dependencies directly.
    ///
    /// Used only by ``AdyenDependency`` to get the current value for a dependency
    fileprivate subscript<T>(_ keyPath: KeyPath<AdyenDependencyValues, T>) -> T { self[keyPath: keyPath] }
    
    /// Supply custom test values for specific dependencies
    ///
    /// To supply test values for a whole class you can override the `run` function of `XCTestCase` like:
    /// ```swift
    /// override func run() {
    ///     AdyenDependencyValues.runTestWithValues {
    ///         $0.dependencyToOverride = TestDependency()
    ///     } perform: {
    ///         super.run()
    ///    }
    /// }
    /// ```
    internal static func runTestWithValues(
        _ setup: (inout AdyenDependencyValues) -> Void,
        perform: () -> Void
    ) {
        let currentValues = current
        
        var testValues = AdyenDependencyValues()
        setup(&testValues)
        
        current = testValues
        perform()
        current = currentValues
    }
}

// MARK: - Property wrapper

@_documentation(visibility: internal)
@propertyWrapper
public struct AdyenDependency<T> {
    private let keyPath: KeyPath<AdyenDependencyValues, T>
    public var wrappedValue: T { AdyenDependencyValues.current[keyPath] }
    
    public init(_ keyPath: KeyPath<AdyenDependencyValues, T>) {
        self.keyPath = keyPath
    }
}

// MARK: - DependencyKey Protocol

@_documentation(visibility: internal)
public protocol AdyenDependencyKey {
    associatedtype Value
    static var liveValue: Self.Value { get }
}
