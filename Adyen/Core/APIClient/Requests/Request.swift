//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}

/// :nodoc:
/// Represents an API request.
public protocol Request: Encodable {
    
    /// :nodoc:
    /// The type of the expected response.
    associatedtype ResponseType: Response
    
    /// :nodoc:
    /// The request path.
    var path: String { get }
    
    /// :nodoc:
    /// How many times the request has been tried.
    var counter: UInt { get set }
    
    /// :nodoc:
    /// The HTTP headers.
    var headers: [String: String] { get }
    
    /// :nodoc:
    /// The query parameters.
    var queryParameters: [URLQueryItem] { get }
    
    /// :nodoc:
    /// The HTTP method.
    var method: HTTPMethod { get }
    
}

/// :nodoc:
/// Represents an API response.
public protocol Response: Decodable {}
