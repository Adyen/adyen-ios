//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct BinLookupRequest: Request {
    
    internal typealias ResponseType = BinLookupResponse
    
    internal var path: String { "checkoutshopper/v1/bin/binLookup" }
    
    internal var counter: UInt = 0
    
    internal var headers: [String: String] = [:]
    
    internal var queryParameters: [URLQueryItem] = []
    
    internal var method: HTTPMethod = .post
    
    internal var encryptedBin: String
    internal var supportedBrands: [CardType]
    
    private enum CodingKeys: String, CodingKey {
        case encryptedBin
        case supportedBrands
    }
}
