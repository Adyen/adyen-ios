//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Conforming to the Observer protocol will make the observe and binding functions available for use.
/// :nodoc:
public protocol Observer: AnyObject {}

/// :nodoc:
public extension Observer {
    
    /// Observes an event publisher for events.
    ///
    /// - Parameters:
    ///   - eventPublisher: The event publisher to observe.
    ///   - eventHandler: A handler to invoke for new events.
    /// - Returns: An observation, representing the created observation. Can be used to remove the observation later.
    @discardableResult
    func observe<T: EventPublisher>(_ eventPublisher: T, eventHandler: @escaping EventHandler<T.Event>) -> Observation {
        observationManager.observe(eventPublisher, eventHandler: eventHandler)
    }
    
    /// Binds the value of an observable to a key path.
    /// It will also set the current value of the observable to the key path.
    ///
    /// - Parameters:
    ///   - observable: The observable to observe for new values.
    ///   - target: The target of where to set the new values.
    ///   - keyPath: The key path to set the new values.
    /// - Returns: An observation that represents the binding. Can be used to remove the binding later.
    @discardableResult
    func bind<Value, Target: AnyObject>(_ observable: AdyenObservable<Value>,
                                        to target: Target,
                                        at keyPath: ReferenceWritableKeyPath<Target, Value>) -> Observation {
        // Set the initial value.
        target[keyPath: keyPath] = observable.wrappedValue
        
        return observe(observable, eventHandler: { [unowned target] newValue in
            target[keyPath: keyPath] = newValue
        })
    }

    /// Binds the value of an observable to an optional key path.
    /// It will also set the current value of the observable to the key path.
    ///
    /// - Parameters:
    ///   - observable: The observable to observe for new values.
    ///   - target: The target of where to set the new values.
    ///   - keyPath: The key path to set the new values.
    /// - Returns: An observation that represents the binding. Can be used to remove the binding later.
    @discardableResult
    func bind<Value, Target: AnyObject>(_ observable: AdyenObservable<Value>,
                                        to target: Target,
                                        at keyPath: ReferenceWritableKeyPath<Target, Value?>) -> Observation {
        // Set the initial value.
        target[keyPath: keyPath] = observable.wrappedValue

        return observe(observable, eventHandler: { [unowned target] newValue in
            target[keyPath: keyPath] = newValue
        })
    }

    /// Binds the transformed value of an observable to a key path.
    /// It will also set the current value of the observable to the key path.
    ///
    /// - Parameters:
    ///   - observable: The observable to observe for new values.
    ///   - target: The target of where to set the new values.
    ///   - keyPath: The key path to set the new values.
    ///   - transformation: The transformation closure.
    /// - Returns: An observation that represents the binding. Can be used to remove the binding later.
    @discardableResult
    func bind<Value, Result, Target: AnyObject>(_ observable: AdyenObservable<Value>,
                                                to target: Target,
                                                at keyPath: ReferenceWritableKeyPath<Target, Result>,
                                                with transformation: @escaping ((Value) -> Result)) -> Observation {
        // Set the initial value.
        target[keyPath: keyPath] = transformation(observable.wrappedValue)

        return observe(observable, eventHandler: { [unowned target] newValue in
            target[keyPath: keyPath] = transformation(newValue)
        })
    }

    /// Binds the sub-value of an observable to a key path.
    /// It will also set the current value of the observable to the key path.
    ///
    /// - Parameters:
    ///   - observable: The observable to observe for new values.
    ///   - originKeyPath: The key path in value.
    ///   - target: The target of where to set the new values.
    ///   - keyPath: The key path to set the new values.
    /// - Returns: An observation that represents the binding. Can be used to remove the binding later.
    @discardableResult
    func bind<Value, Result, Target: AnyObject>(_ observable: AdyenObservable<Value>,
                                                at originKeyPath: KeyPath<Value, Result>,
                                                to target: Target,
                                                at keyPath: ReferenceWritableKeyPath<Target, Result>) -> Observation {
        // Set the initial value.
        target[keyPath: keyPath] = observable.wrappedValue[keyPath: originKeyPath]

        return observe(observable, eventHandler: { [unowned target] newValue in
            target[keyPath: keyPath] = newValue[keyPath: originKeyPath]
        })
    }

    /// Binds the sub-value of an observable to an optional  key path.
    /// It will also set the current value of the observable to the key path.
    ///
    /// - Parameters:
    ///   - observable: The observable to observe for new values.
    ///   - originKeyPath: The key path in value.
    ///   - target: The target of where to set the new values.
    ///   - keyPath: The key path to set the new values.
    /// - Returns: An observation that represents the binding. Can be used to remove the binding later.
    @discardableResult
    func bind<Value, Result, Target: AnyObject>(_ observable: AdyenObservable<Value>,
                                                at originKeyPath: KeyPath<Value, Result>,
                                                to target: Target,
                                                at keyPath: ReferenceWritableKeyPath<Target, Result?>) -> Observation {
        // Set the initial value.
        target[keyPath: keyPath] = observable.wrappedValue[keyPath: originKeyPath]

        return observe(observable, eventHandler: { [unowned target] newValue in
            target[keyPath: keyPath] = newValue[keyPath: originKeyPath]
        })
    }
    
    /// Removes an observation.
    ///
    /// - Parameter observation: The observation to remove.
    func remove(_ observation: Observation) {
        observationManager.remove(observation)
    }
    
    // MARK: - Observation Manager
    
    /// The observation manager that manages the observations of the observer.
    private var observationManager: ObservationManager {
        let existingObservationManager = objc_getAssociatedObject(self, &AssociatedKeys.observationManager)
        if let observationManager = existingObservationManager as? ObservationManager {
            return observationManager
        }
        
        let observationManager = ObservationManager()
        objc_setAssociatedObject(self,
                                 &AssociatedKeys.observationManager,
                                 observationManager,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return observationManager
    }
    
}

/// The keys used for associated objects.
private enum AssociatedKeys {
    
    /// The observation manager associated with the object.
    public static var observationManager = "observationManager"
    
}
