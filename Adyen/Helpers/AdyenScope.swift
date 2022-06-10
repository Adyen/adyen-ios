//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A wrapper around a base instance, to enable scoped system types extensions without conflict with the host app code.
@_spi(AdyenInternal)
public struct AdyenScope<Base> {
    
    public let base: Base
    
    public init(base: Base) {
        self.base = base
    }
}

/// Describes a type that needs scoped extension.
@_spi(AdyenInternal)
public protocol AdyenCompatible {
    
    associatedtype AdyenBase
    
    var adyen: AdyenScope<AdyenBase> { get }
}

/// Provides default implementation of the `adyen` property,
/// to enable any conforming type to inherit the `adyen` scope.
@_spi(AdyenInternal)
public extension AdyenCompatible {
    
    var adyen: AdyenScope<Self> {
        AdyenScope(base: self)
    }
}
