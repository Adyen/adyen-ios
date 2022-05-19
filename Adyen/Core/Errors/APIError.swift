//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents an API error object.
@_spi(AdyenInternal)
public struct APIError: Decodable, Error, LocalizedError {
    
    /// The status.
    public let status: Int?
    
    /// The error code.
    public let errorCode: String
    
    /// The error message.
    public let errorMessage: String
    
    /// The error type.
    public let type: APIErrorType
    
    /// The error human readable description.
    public var errorDescription: String? {
        errorMessage
    }

    private enum CodingKeys: String, CodingKey {
        case status, errorCode, errorMessage = "message", type = "errorType"
    }
    
}

/// Represents an API error type.
@_spi(AdyenInternal)
public enum APIErrorType: String, Decodable {
    case `internal`
    case validation
    case security
    case configuration
    case urlError
    case noInternet
    case sessionExpired
}
