//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Error type.
public enum Error: Swift.Error {
    
    /// Error returned from server.
    case serverError(String)
    
    /// Network error.
    case networkError(Swift.Error)
    
    /// Unexpected data or data format.
    case unexpectedData
    
    /// Unexpected error.
    case unexpectedError
    
    /// Payment was cancelled.
    case cancelled
    
}

// MARK: - Equatable

extension Error: Equatable {
    
    /// :nodoc:
    public static func ==(lhs: Error, rhs: Error) -> Bool {
        switch (lhs, rhs) {
        case let (.serverError(serverError1), .serverError(serverError2)):
            return serverError1 == serverError2
        case (.unexpectedData, .unexpectedData):
            return true
        case (.unexpectedError, .unexpectedError):
            return true
        case (.cancelled, .cancelled):
            return true
        default:
            return false
        }
    }
    
}

// MARK: - LocalizedError

extension Error: LocalizedError {
    
    // MARK: - Error Description
    
    public var errorDescription: String? {
        switch self {
        case let .serverError(message):
            return message
        case let .networkError(error):
            return error.localizedDescription
        case .unexpectedData:
            return "Unexpected data was returned from the server."
        case .cancelled:
            return "Payment was cancelled."
        default:
            return "Unexpected error."
        }
    }
    
}
