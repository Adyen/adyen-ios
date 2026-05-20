//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Conforming types can publish observable events.
package protocol EventPublisher: AnyObject {

    /// The type of event published.
    associatedtype Event
    
    /// The event handlers that are attached to the publisher.
    var eventHandlers: [EventHandlerToken: EventHandler<Event>] { get set }
    
    var eventHandlersLock: NSLock { get }
}

package extension EventPublisher {

    /// Adds an event handler.
    ///
    /// - Parameter eventHandler: The event handler to add.
    /// - Returns: A token, used to identify and later remove the event handler.
    func addEventHandler(_ eventHandler: @escaping EventHandler<Event>) -> EventHandlerToken {
        let token = EventHandlerToken()
        eventHandlersLock.withLock {
            eventHandlers[token] = eventHandler
        }
        
        return token
    }
    
    /// Removes an event handler.
    ///
    /// - Parameter token: The token associated with the event handler to remove.
    func removeEventHandler(with token: EventHandlerToken) {
        _ = eventHandlersLock.withLock {
            eventHandlers.removeValue(forKey: token)
        }
    }
    
    /// Publishes an event.
    ///
    /// - Parameter event: The event to publish.
    func publish(_ event: Event) {
        let handlers = eventHandlersLock.withLock {
            Array(eventHandlers.values)
        }
        
        handlers.forEach { eventHandler in
            eventHandler(event)
        }
    }
    
    /// default extension to satisfy lib evolution
    var eventHandlersLock: NSLock {
        NSLock()
    }
}

/// Alias for a closure that handles an event.
package typealias EventHandler<Event> = (Event) -> Void

/// Represents a token that references the event handler.
package struct EventHandlerToken: Hashable {
    private let uuid = UUID()
}
