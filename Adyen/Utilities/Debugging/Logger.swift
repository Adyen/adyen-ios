//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import func Darwin.fputs

/// Provides control over SDK logging.
public enum AdyenLogging {
    /// Indicates whether to enable printing to the console.
    public static var isEnabled: Bool = false {
        didSet {
            AdyenNetworking.Logging.isEnabled = isEnabled
        }
    }
}

/// :nodoc:
/// Copies the interface of `Swift.print()`,
/// and `Swift.print()` is called inside after checking first if `AdyenLogging.isEnabled` is `true`, and returns if `false`.
public func adyenPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    guard AdyenLogging.isEnabled else { return }
    var idx = items.startIndex
    let endIdx = items.endIndex
    
    repeat {
        Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
        idx += 1
    } while idx < endIdx
}
