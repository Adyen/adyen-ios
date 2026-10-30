//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Immutable additional callbacks looked up by type.
///
/// When a type occurs more than once, the last entry wins.
package struct AdditionalCallbacksStore {

    private let entries: [Any]

    package init(_ callbacks: [Any] = []) {
        entries = callbacks
    }

    package func callbacks<T>(of type: T.Type) -> T? {
        entries.last { $0 is T } as? T
    }
}
