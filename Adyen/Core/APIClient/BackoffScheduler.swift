//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Decides what interval should be used to delay the next event, based on how many times the event has been fired before.
internal protocol IntervalCalculator {
    func interval(for counter: UInt) -> DispatchTimeInterval
}

/// :nodoc:
/// 2 seconds between the first 20 events, and then 10 seconds between the next 80 events,
/// then `DispatchTimeInterval.never` is returned after that.
internal struct BackoffIntervalCalculator: IntervalCalculator {
    
    /// :nodoc:
    internal func interval(for counter: UInt) -> DispatchTimeInterval {
        if counter <= 20 {
            return .seconds(2)
        } else if counter <= 100 {
            return .seconds(10)
        } else {
            return .never
        }
    }
}

/// :nodoc:
/// Scheduler of closures with increasing interval between dispatching's, with maximum of 100 times,
/// how intervals are calculated is decided by injecting an `IntervalCalculator` implementation.
public struct BackoffScheduler: Scheduler {
    
    /// :nodoc:
    private let queue: DispatchQueue
    
    /// :nodoc:
    internal var backoffIntevalCalculator: IntervalCalculator = BackoffIntervalCalculator()
    
    /// :nodoc:
    public init(queue: DispatchQueue) {
        self.queue = queue
    }
    
    /// :nodoc:
    public func schedule(_ currentCount: UInt, closure: @escaping () -> Void) -> Bool {
        guard currentCount < 100 else { return true }
        
        let dispatchInterval = backoffIntevalCalculator.interval(for: currentCount)
        
        guard dispatchInterval != .never else { return true }
        
        let workItem = DispatchWorkItem(block: closure)
        
        queue.asyncAfter(deadline: DispatchTime.now() + dispatchInterval, execute: workItem)
        
        return false
    }
}
