//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum CallbackError: LocalizedError {
    case missingSubmitHandler
    case missingAdditionalDetailsHandler
    case unsupportedSubmit
    case beforeSubmitAborted

    internal var errorDescription: String? {
        switch self {
        case .missingSubmitHandler:
            "Checkout requires `onSubmit` to submit payment data."
        case .missingAdditionalDetailsHandler:
            "Checkout requires `onAdditionalDetails` to submit additional details."
        case .unsupportedSubmit:
            "Action-only checkout cannot submit payment data."
        case .beforeSubmitAborted:
            "Submission was aborted by the `onBeforeSubmit` callback."
        }
    }
}
