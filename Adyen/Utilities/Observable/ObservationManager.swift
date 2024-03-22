//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Manages all the observations of an observer.
internal class ObservationManager {
    
    deinit {
        observations.forEach {
            $0.unobserveHandler()
        }
    }
    
    // MARK: - Adding and Removing Observations
    
    internal func observe<T: EventPublisher>(_ eventPublisher: T, eventHandler: @escaping EventHandler<T.Event>) -> Observation {
        let eventHandlerToken = eventPublisher.addEventHandler(eventHandler)
        
        let observation = Observation(unobserveHandler: { [weak eventPublisher] in
            eventPublisher?.removeEventHandler(with: eventHandlerToken)
        })
        observations.append(observation)
        
        return observation
    }
    
    internal func remove(_ observation: Observation) {
        guard let index = observations.firstIndex(of: observation) else {
            return
        }
        
        observations.remove(at: index)
        
        observation.unobserveHandler()
    }
    
    private var observations = [Observation]()
    
}
