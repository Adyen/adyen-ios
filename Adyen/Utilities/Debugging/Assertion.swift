//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import os

/// A typealias for a closure that handles a URL through which the application was opened.
package typealias AssertionListener = @Sendable (String) -> Void

package enum AdyenAssertion {

    /// TODO: Robert: Swift6: This may be of a concern. Have a closer look at this. Why cant this be on the main actor instea of usign locks?
    private static let listenerStorage = OSAllocatedUnfairLock<AssertionListener?>(initialState: nil)

    internal static var listener: AssertionListener? {
        get {
            listenerStorage.withLock { $0 }
        }
        set {
            listenerStorage.withLock { $0 = newValue }
        }
    }

    /// Calls `assertionFailure` when not running Tests.
    package static func assertionFailure(message: @autoclosure () -> String) {
        if CommandLine.arguments.contains("-UITests") {
            listener?(message())
            return
        }
        Swift.assertionFailure(message())
    }

    /// Calls `assertFailure(message:)` when condition is true.
    package static func assert(message: @autoclosure () -> String, condition: @autoclosure () -> Bool) {
        guard condition() else {
            return
        }
        assertionFailure(message: message())
    }
}
