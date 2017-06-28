//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Error type.
public enum Error: Swift.Error {
    
    /// Error with a message. This enum case is deprecated. Please use `serverError` instead.
    @available(*, deprecated, message: "Please use serverError instead.")
    case message(String)
    
    /// Error returned from server.
    case serverError(String)
    
    /// Network error.
    case networkError(Swift.Error)
    
    /// Unexpected data or data format.
    case unexpectedData
    
    /// Unexpected error.
    case unexpectedError
    
    /// Payment was canceled.
    case canceled
}

extension Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .message(message):
            return message
        case let .serverError(message):
            return message
        case let .networkError(error):
            return error.localizedDescription
        case .unexpectedData:
            return "Unexpected data was returned from the server."
        case .canceled:
            return "Payment was canceled."
        default:
            return "Unexpected error."
        }
    }
}
