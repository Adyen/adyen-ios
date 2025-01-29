//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension AdyenScope {
    /// Safely returns the value at the given index if within bounds. Returns `nil` otherwise.
    subscript<T>(safeIndex index: Int) -> T? where Base == [T] {
        guard index >= base.startIndex,
              index < base.endIndex else { return nil }
        return base[index]
    }
}
