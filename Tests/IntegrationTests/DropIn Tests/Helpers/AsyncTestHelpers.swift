//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Polls until the condition is met, to give detached payment tasks a chance to progress.
@MainActor
func waitUntil(
    _ condition: () -> Bool,
    timeout: TimeInterval = 5,
    pollingInterval: TimeInterval = 0.01
) async {
    let deadline = Date().addingTimeInterval(timeout)

    while !condition(), Date() < deadline {
        await Task.yield()
        try? await Task.sleep(nanoseconds: UInt64(pollingInterval * Double(NSEC_PER_SEC)))
    }
}
