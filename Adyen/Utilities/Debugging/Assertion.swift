//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A typealias for a closure that handles a URL through which the application was opened.
/// :nodoc:
public typealias AssertionListner = (String) -> Void

/// :nodoc:
public enum AdyenAssertion {

    internal static var listner: AssertionListner?

    /// :nodoc:
    /// Calls `assertionFailure` when not runing Tests.
    public static func assert(message: String) {
        if CommandLine.arguments.contains("-UITests") {
            listner?(message)
            return
        }

        assertionFailure(message)
    }
}
