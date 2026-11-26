//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// AdyenNetworking does not annotate `Logging.isEnabled` for concurrency; remove `@preconcurrency` once it does.
@preconcurrency import AdyenNetworking
import func Darwin.fputs
import os

/// The level of the SDK logs, ordered from most to least verbose. Set it with `Checkout.setLogLevel(_:)`.
public enum CheckoutLogLevel: Sendable {
    /// Logs everything the SDK logs, including networking.
    ///
    /// Only use this level during development. The logs include request URLs with the client key,
    /// and request and response headers and bodies.
    case verbose

    /// Logs nothing. This is the default.
    case off
}

/// Provides control over SDK logging.
package enum AdyenLogging {

    private static let storage = OSAllocatedUnfairLock(initialState: false)

    /// Indicates whether to enable printing to the console.
    package static var isEnabled: Bool {
        get {
            storage.withLock { $0 }
        }
        set {
            storage.withLock {
                $0 = newValue
                AdyenNetworking.Logging.isEnabled = newValue
            }
        }
    }
}

/// Copies the interface of `Swift.print()`,
/// and `Swift.print()` is called inside after checking first if `AdyenLogging.isEnabled` is `true`, and returns if `false`.
package func adyenPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    guard AdyenLogging.isEnabled else { return }
    var idx = items.startIndex
    let endIdx = items.endIndex
    
    repeat {
        Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
        idx += 1
    } while idx < endIdx
}
