//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

package typealias CheckoutSubmitHandler = @MainActor @Sendable (_ data: PaymentComponentData) async -> SubmitResult
package typealias CheckoutAdditionalDetailsHandler = @MainActor @Sendable (_ data: ActionComponentData) async -> AdditionalDetailsResult
package typealias CheckoutBeforeSubmitHandler = @MainActor @Sendable (_ data: BeforeSubmitData) async -> BeforeSubmitResult
package typealias CheckoutActionHandler = @MainActor @Sendable (_ actionData: ActionData, _ actionViewController: UIViewController) -> Void

package typealias CheckoutCompletionHandler = @MainActor @Sendable (_ result: CheckoutResult) -> Void
package typealias AdvancedCheckoutCompletionHandler = @MainActor @Sendable (_ result: AdvancedCheckoutResult) -> Void
package typealias CheckoutFailureHandler = @MainActor @Sendable (_ error: CheckoutError) -> Void
