//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct APIError: Decodable, Error, LocalizedError {
    
    internal let status: Int
    
    internal let errorCode: String
    
    internal let message: String
    
    internal let errorType: APIErrorType
    
    internal var errorDescription: String? {
        message
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
