//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

package typealias StoredPaymentMethodRemovalHandler = @MainActor @Sendable (StoredPaymentMethod) async throws -> Void

package enum StoredPaymentMethodRemovalError: Error, Equatable {
    case unavailable
    case unsuccessful
}
