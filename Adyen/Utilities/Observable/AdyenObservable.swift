//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Wraps a value to make it observable.
@propertyWrapper
public final class AdyenObservable<ValueType: Equatable>: EventPublisher {
    
    /// Initializes the observable.
    ///
    /// - Parameter value: The initial value.
    public init(_ value: ValueType) {
        self.wrappedValue = value
    }
    
    // MARK: - Value

    /// The value being observed.
    ///
    /// When this value is updated, the observable will only publish the new value to subscribers
    /// if it is not equal to the previous value (using the `!=` operator). This differs from most
    /// reactive frameworks, which typically publish all updates regardless of value equality.
    ///
    /// - Note: This equality-based publishing behavior is part of the framework design but ideally
    ///         should be a responsibility of the business logic layer rather than the reactive framework.
    ///         When implementing custom observers, consider whether this behavior is appropriate for your use case.
    ///
    /// - Important: If you need to force publication even when values are equal, you'll need to
    ///              explicitly call `publish(value)` instead of setting this property.
    public var wrappedValue: ValueType {
        didSet {
            guard wrappedValue != oldValue else { return }
            
            publish(wrappedValue)
        }
    }
    
    // MARK: - Event Publisher
    
    /// The event published by the observable.
    /// Contains the new value.
    public typealias Event = ValueType
    
    /// The event handlers attached to the observable.
    public var eventHandlers = [EventHandlerToken: EventHandler<Event>]()
    
    public var projectedValue: AdyenObservable { self }
    
}
