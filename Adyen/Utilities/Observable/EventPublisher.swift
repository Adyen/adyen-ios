//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Conforming types can publish observable events.
/// :nodoc:
public protocol EventPublisher: AnyObject {
    
    /// The type of event published.
    associatedtype Event
    
    /// The event handlers that are attached to the publisher.
    var eventHandlers: [EventHandlerToken: EventHandler<Event>] { get set }
    
}

/// :nodoc:
public extension EventPublisher {
    
    /// Adds an event handler.
    ///
    /// - Parameter eventHandler: The event handler to add.
    /// - Returns: A token, used to identify and later remove the event handler.
    func addEventHandler(_ eventHandler: @escaping EventHandler<Event>) -> EventHandlerToken {
        let token = EventHandlerToken()
        eventHandlers[token] = eventHandler
        
        return token
    }
    
    /// Removes an event handler.
    ///
    /// - Parameter token: The token associated with the event handler to remove.
    func removeEventHandler(with token: EventHandlerToken) {
        eventHandlers.removeValue(forKey: token)
    }
    
    /// Publishes an event.
    ///
    /// - Parameter event: The event to publish.
    func publish(_ event: Event) {
        eventHandlers.forEach { _, eventHandler in
            eventHandler(event)
        }
    }
    
}

/// Alias for a closure that handles an event.
/// :nodoc:
public typealias EventHandler<Event> = (Event) -> Void

/// Represents a token that references the event handler.
/// :nodoc:
public struct EventHandlerToken: Hashable {
    private let uuid = UUID()
}
