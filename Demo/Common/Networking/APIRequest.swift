//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenNetworking
import Foundation

internal protocol APIRequest: Request where ErrorResponseType == APIError {}

internal struct APIError: ErrorResponse, LocalizedError {
    
    /// The status.
    internal let status: Int?

    /// The error code.
    internal let errorCode: String

    /// The error message.
    internal let errorMessage: String

    /// The error type.
    internal let type: APIErrorType

    /// The error human readable description.
    internal var errorDescription: String? {
        errorMessage
    }

    private enum CodingKeys: String, CodingKey {
        case status, errorCode, errorMessage = "message", type = "errorType"
    }
    
}

internal enum APIErrorType: String, Decodable {
    case `internal`
    case validation
    case security
    case configuration
    case urlError
    case noInternet
    case sessionExpired
}
