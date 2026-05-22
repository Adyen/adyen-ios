//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Represents an API error object.
package struct APIError: ErrorResponse, LocalizedError {

    /// The status.
    package let status: Int?

    /// The error code.
    package let errorCode: String

    /// The error message.
    package let errorMessage: String

    /// The error type.
    package let type: APIErrorType

    /// The error human readable description.
    package var errorDescription: String? {
        errorMessage
    }

    private enum CodingKeys: String, CodingKey {
        case status, errorCode, errorMessage = "message", type = "errorType"
    }
    
}

/// Represents an API error type.
package enum APIErrorType: String, Decodable {
    case `internal`
    case validation
    case security
    case configuration
    case urlError
    case noInternet
    case sessionExpired
}
