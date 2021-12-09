//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A property wrapper to enable a property to be lazily initialized when its first called,
/// with the added ability to nullify it and gets reinitialized when called again.
@propertyWrapper
internal final class LazyOptional<ValueType> {
    
    /// :nodoc:
    private var _wrappedValue: ValueType?
    
    /// :nodoc:
    private let initialize: () -> ValueType
    
    /// Initializes the property wrapper.
    ///
    /// - Parameter initialize: A closure that builds the wrapped object when needed.
    internal init(initialize: @autoclosure @escaping () -> ValueType) {
        self.initialize = initialize
    }
    
    /// :nodoc:
    internal var wrappedValue: ValueType {
        
        get {
            if _wrappedValue == nil {
                _wrappedValue = initialize()
            }
            return _wrappedValue!
        }
        
        set {
            _wrappedValue = newValue
        }
        
    }
    
    /// :nodoc:
    internal var projectedValue: LazyOptional { self }
    
    /// Dealloc the property, and it will get initialized when called again.
    internal func reset() {
        _wrappedValue = nil
    }
}
