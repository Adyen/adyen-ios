//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public typealias SubmitHandler = @MainActor @Sendable (_ data: PaymentComponentData) async -> SubmitResult
public typealias AdditionalDetailsHandler = @MainActor @Sendable (_ data: ActionComponentData) async -> AdditionalDetailsResult
public typealias BeforeSubmitHandler = @MainActor @Sendable (_ data: BeforeSubmitData) async -> BeforeSubmitResult

package typealias SessionCheckoutCompletionHandler = @MainActor (_ result: SessionCheckoutResult) -> Void
package typealias AdvancedCheckoutCompletionHandler = @MainActor (_ result: AdvancedCheckoutResult) -> Void
package typealias CheckoutFailureHandler = @MainActor (_ error: CheckoutError) -> Void
