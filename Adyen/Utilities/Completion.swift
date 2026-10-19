//
// Copyright (c) 2017 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Alias for a completion handler with a single parameter of type T.
package typealias Completion<T> = (T) -> Void

/// Alias for a completion handler with no parameters.
/// Note i cannot use the Completion<T> type as Completion<Void> as that would make the call site become completion(Void) or completion(())
package typealias VoidCompletion = () -> Void
