//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Wraps a value to make it observable.
/// :nodoc:
public final class Observable<ValueType: Equatable>: EventPublisher {
    
    /// Initializes the observable.
    ///
    /// - Parameter value: The initial value.
    public init(_ value: ValueType) {
        self.value = value
    }
    
    // MARK: - Value
    
    /// The observable value.
    public var value: ValueType {
        didSet {
            if value == oldValue {
                return
            }
            
            publish(value)
        }
    }
    
    // MARK: - Event Publisher
    
    /// The event published by the observable.
    /// Contains the new value.
    public typealias Event = ValueType
    
    /// The event handlers attached to the observable.
    public var eventHandlers = [EventHandlerToken: EventHandler<Event>]()
    
}
