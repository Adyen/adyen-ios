//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Scheduler of closures with maximum number of scheduling times, and closures are fired right away with no delay.
public struct SimpleScheduler: Scheduler {
    
    /// :nodoc:
    private let maximumCount: Int
    
    /// :nodoc:
    public init(maximumCount: Int) {
        self.maximumCount = maximumCount
    }
    
    /// :nodoc:
    public func schedule(_ currentCount: UInt, closure: @escaping () -> Void) -> Bool {
        guard currentCount < maximumCount else { return true }
        
        closure()
        
        return false
    }
}
