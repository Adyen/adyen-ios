//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Manages all the observations of an observer.
package class ObservationManager {
    
    private var observations = [Observation]()
    private let lock = NSLock()

    package init() {}

    deinit {
        let observationsToRemove = lock.withLock {
            let copy = observations
            observations = []
            return copy
        }
        
        observationsToRemove.forEach {
            $0.unobserveHandler()
        }
    }
    
    // MARK: - Adding and Removing Observations
    
    package func observe<T: EventPublisher>(_ eventPublisher: T, eventHandler: @escaping EventHandler<T.Event>) -> Observation {
        let eventHandlerToken = eventPublisher.addEventHandler(eventHandler)
        
        let observation = Observation(unobserveHandler: { [weak eventPublisher] in
            eventPublisher?.removeEventHandler(with: eventHandlerToken)
        })
        
        lock.withLock {
            observations.append(observation)
        }
        
        return observation
    }
    
    package func remove(_ observation: Observation) {
        lock.withLock {
            observations.removeAll { element in
                element == observation
            }
        }
        observation.unobserveHandler()
    }
}
