//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Yields until the condition is met, to give detached payment tasks a chance to progress.
@MainActor
func waitUntil(
    _ condition: () -> Bool,
    iterations: Int = 100
) async {
    for _ in 0..<iterations {
        if condition() {
            return
        }
        await Task.yield()
    }
}
