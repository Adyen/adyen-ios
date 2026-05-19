//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal enum CallbackError: LocalizedError {
    case missingSubmitHandler
    case missingAdditionalDetailsHandler
    case unsupportedSubmit

    internal var errorDescription: String? {
        switch self {
        case .missingSubmitHandler:
            "Checkout requires `onSubmit` to submit payment data."
        case .missingAdditionalDetailsHandler:
            "Checkout requires `onAdditionalDetails` to submit additional details."
        case .unsupportedSubmit:
            "Action-only checkout cannot submit payment data."
        }
    }
}
