//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

@_spi(AdyenInternal)
public struct ClientKeyRequest: APIRequest {
    
    public typealias ResponseType = ClientKeyResponse
    
    public var path: String { "checkoutshopper/v1/clientKeys/\(clientKey)" }
    
    public let clientKey: String
    
    public var counter: UInt = 0
    
    public let headers: [String: String] = [:]
    
    public let queryParameters: [URLQueryItem] = []
    
    public let method: HTTPMethod = .get
    
    public init(clientKey: String) {
        self.clientKey = clientKey
    }
    
    private enum CodingKeys: CodingKey {}
    
}
