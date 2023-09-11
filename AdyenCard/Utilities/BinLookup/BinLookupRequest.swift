//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal enum BinLookupRequestType: String, Codable {
    case card
    case bcmc
}

internal struct BinLookupRequest: APIRequest {
    
    internal typealias ResponseType = BinLookupResponse
    
    internal var path: String = "checkoutshopper/v2/bin/binLookup"
    
    internal var counter: UInt = 0
    
    internal var headers: [String: String] = [:]
    
    internal var queryParameters: [URLQueryItem] = []
    
    internal var method: HTTPMethod = .post
    
    internal var encryptedBin: String

    internal var supportedBrands: [CardType]
    
    internal let requestId = UUID().uuidString
    
    internal let type: BinLookupRequestType
    
    private enum CodingKeys: String, CodingKey {
        case encryptedBin
        case supportedBrands
        case requestId
        case type
    }
}
