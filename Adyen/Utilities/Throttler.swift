//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// Throttles come code execution.
/// :nodoc:
public final class Throttler {
    
    private var workItem = DispatchWorkItem(block: { /* first work item is idle */ })
    private let queue: DispatchQueue
    private let minimumDelay: TimeInterval
    
    /// :nodoc:
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
        workItem = DispatchWorkItem(block: block)

        // => delay the workItem execution by the minimum delay time
        queue.asyncAfter(deadline: .now() + minimumDelay, execute: workItem)
    }
}
