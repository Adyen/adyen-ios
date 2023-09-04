//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

enum BinLookupRequestType: String, Codable {
    case card
    case bcmc
}

struct BinLookupRequest: APIRequest {
    
    typealias ResponseType = BinLookupResponse
    
    var path: String = "checkoutshopper/v2/bin/binLookup"
    
    var counter: UInt = 0
    
    var headers: [String: String] = [:]
    
    var queryParameters: [URLQueryItem] = []
    
    var method: HTTPMethod = .post
    
    var encryptedBin: String

    var supportedBrands: [CardType]
    
    let requestId = UUID().uuidString
    
    let type: BinLookupRequestType
    
    private enum CodingKeys: String, CodingKey {
        case encryptedBin
        case supportedBrands
        case requestId
        case type
    }
}
