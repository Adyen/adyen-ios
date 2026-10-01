//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

public typealias CheckoutSubmitHandler = @MainActor @Sendable (_ data: PaymentComponentData) async -> SubmitResult
public typealias CheckoutAdditionalDetailsHandler = @MainActor @Sendable (_ data: ActionComponentData) async -> AdditionalDetailsResult
public typealias CheckoutBeforeSubmitHandler = @MainActor @Sendable (_ data: BeforeSubmitData) async -> BeforeSubmitResult
public typealias CheckoutActionHandler = @MainActor @Sendable (_ actionData: ActionData, _ actionViewController: UIViewController) -> Void

package typealias SessionCheckoutCompletionHandler = @MainActor (_ result: SessionCheckoutResult) -> Void
package typealias AdvancedCheckoutCompletionHandler = @MainActor (_ result: AdvancedCheckoutResult) -> Void
package typealias CheckoutFailureHandler = @MainActor (_ error: CheckoutError) -> Void
