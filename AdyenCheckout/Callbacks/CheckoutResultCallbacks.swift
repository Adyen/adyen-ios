//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

package protocol CheckoutResultCallbacks {
    @MainActor
    func handleCompletion(resultCode: CheckoutResultCode, sessionId: String?, sessionResult: String?)

    var onFailure: CheckoutFailureHandler { get }

    var onAction: CheckoutActionHandler? { get }
}
