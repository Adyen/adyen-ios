//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Scheduler of closures.
public protocol Scheduler {
    
    /// :nodoc:
    /// Schedule a closure according to how many times it has beed scheduled before.
    ///
    /// - Parameter currentCount: How many times it has beed scheduled before.
    /// - Returns: A boolean value indicating whether it has stopped scheduling,
    ///  for example because the `currentCount` reached a maximum scheduling count.
    func schedule(_ currentCount: UInt, closure: @escaping () -> Void) -> Bool
}
