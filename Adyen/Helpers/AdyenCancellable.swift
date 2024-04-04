//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package protocol AdyenCancellable {
    func cancel()
}

/// Indicates whether or not a task should be cancelled
package class AdyenTask: AdyenCancellable {
    public private(set) var isCancelled: Bool = false
    public func cancel() {
        isCancelled = true
        onCancellation()
    }
    
    private let onCancellation: () -> Void
    
    internal init(onCancellation: @escaping () -> Void) {
        self.onCancellation = onCancellation
    }
}
