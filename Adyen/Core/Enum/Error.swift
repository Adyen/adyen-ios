//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Error type.
public enum Error: Swift.Error {
    /// Error with a message.
    case message(String)
    
    /// Network error.
    case networkError(Swift.Error)
    
    /// Unexpected data or data format.
    case unexpectedData
    
    /// Unexpected error.
    case unexpectedError
    
    /// Payment was canceled.
    case canceled
}
