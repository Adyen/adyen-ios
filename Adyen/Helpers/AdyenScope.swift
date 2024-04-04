//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A wrapper around a base instance, to enable scoped system types extensions without conflict with the host app code.
package struct AdyenScope<Base> {
    
    public let base: Base
    
    public init(base: Base) {
        self.base = base
    }
}

/// Describes a type that needs scoped extension.
package protocol AdyenCompatible {
    
    associatedtype AdyenBase
    
    var adyen: AdyenScope<AdyenBase> { get }
}

/// Provides default implementation of the `adyen` property,
/// to enable any conforming type to inherit the `adyen` scope.
package extension AdyenCompatible {
    
    var adyen: AdyenScope<Self> {
        AdyenScope(base: self)
    }
}
