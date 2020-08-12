//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Represents any API and its different environments (test, beta, and live).
public protocol APIEnvironment {
    
    /// :nodoc:
    /// The base url.
    var baseURL: URL { get }
    
    /// :nodoc:
    /// The HTTP headers.
    var headers: [String: String] { get }
    
    /// :nodoc:
    /// The query parameters.
    var queryParameters: [URLQueryItem] { get }
    
}
