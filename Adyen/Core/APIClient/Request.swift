//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
}

public protocol Request: Encodable {
    
    associatedtype ResponseType: Response
    
    var path: String { get }
    
    var counter: Int { get set }
    
    var headers: [String: String] { get }
    
    var queryParameters: [URLQueryItem] { get }
    
    var method: HTTPMethod { get }
    
}

extension Request {
    internal var headers: [String: String] {
        [
            "Content-Type": "application/json"
        ]
    }
}

public protocol Response: Decodable {}
