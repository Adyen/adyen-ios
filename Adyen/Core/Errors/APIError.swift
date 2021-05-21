//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Represents an API error object.
public struct APIError: Decodable, Error, LocalizedError {
    
    /// :nodoc:
    /// The status.
    public let status: Int?
    
    /// :nodoc:
    /// The error code.
    public let errorCode: String
    
    /// :nodoc:
    /// The error message.
    public let errorMessage: String
    
    /// :nodoc:
    /// The error type.
    public let type: APIErrorType
    
    /// :nodoc:
    /// The error human readable description.
    public var errorDescription: String? {
        errorMessage
    }

    private enum CodingKeys: String, CodingKey {
        case status, errorCode, errorMessage = "message", type = "errorType"
    }
    
}

/// :nodoc:
/// Represents an API error type.
public enum APIErrorType: String, Decodable {
    case `internal`
    case validation
    case security
    case configuration
    case urlError
    case noInternet
    case sessionExpired
}
