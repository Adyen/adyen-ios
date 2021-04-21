//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// Throttles requests.
internal final class Throttler {
    
    private var workItem = DispatchWorkItem(block: { /* first work item is idle */ })
    private var previousRun = Date.distantPast
    private let queue: DispatchQueue
    private let minimumDelay: TimeInterval
    
    public init(minimumDelay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.minimumDelay = minimumDelay
        self.queue = queue
    }
    
    /// Throttle a block of code after `minimumDelay`.
    /// - Parameter block: Block of code to be throttled.
    public func throttle(_ block: @escaping () -> Void) {
        // Cancel any existing work item if it has not yet executed
        workItem.cancel()
        
        // Re-assign workItem with the new block task, resetting the previousRun time when it executes
        workItem = DispatchWorkItem { [weak self] in
            self?.previousRun = Date()
            block()
        }
        
        // If the time since the previous run is more than the required minimum delay
        // => execute the workItem immediately
        // else
        // => delay the workItem execution by the minimum delay time
        let delay = previousRun.timeIntervalSinceNow > minimumDelay ? 0 : minimumDelay
        queue.asyncAfter(deadline: .now() + Double(delay), execute: workItem)
    }
}
