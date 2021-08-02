//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A wrapper around a base instance, to enable scoped system types extensions without conflict with the host app code.
/// :nodoc:
public struct AdyenScope<Base> {
    
    /// :nodoc:
    public let base: Base
    
    /// :nodoc:
    public init(base: Base) {
        self.base = base
    }
}

/// Describes a type that needs scoped extension.
/// :nodoc:
public protocol AdyenCompatible {
    
    /// :nodoc:
    associatedtype AdyenBase
    
    /// :nodoc:
    var adyen: AdyenScope<AdyenBase> { get }
}

/// Provides default implementation of the `adyen` property,
/// to enable any conforming type to inherit the `adyen` scope.
/// :nodoc:
public extension AdyenCompatible {
    
    /// :nodoc:
    var adyen: AdyenScope<Self> {
        AdyenScope(base: self)
    }
}
