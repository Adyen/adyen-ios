//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// :nodoc:
public struct ClientKeyRequest: APIRequest {
    
    /// :nodoc:
    public typealias ResponseType = ClientKeyResponse
    
    /// :nodoc:
    public var path: String { "checkoutshopper/v1/clientKeys/\(clientKey)" }
    
    /// :nodoc:
    public let clientKey: String
    
    /// :nodoc:
    public var counter: UInt = 0
    
    /// :nodoc:
    public let headers: [String: String] = [:]
    
    /// :nodoc:
    public let queryParameters: [URLQueryItem] = []
    
    /// :nodoc:
    public let method: HTTPMethod = .get
    
    /// :nodoc:
    public init(clientKey: String) {
        self.clientKey = clientKey
    }
    
    private enum CodingKeys: CodingKey {}
    
}
