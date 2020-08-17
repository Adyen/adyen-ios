//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct BinLookupRequest: Request {
    
    internal typealias ResponseType = BinLookupResponse
    
    internal var path: String = "binLookup"
    
    internal var counter: UInt = 0
    
    internal var headers: [String: String] = [:]
    
    internal var queryParameters: [URLQueryItem] = []
    
    internal var method: HTTPMethod = .post
    
    internal var clientKey: String
    internal var encryptedBin: String
    internal var supportedBrands: [CardType]
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clientKey, forKey: .clientKey)
        try container.encode(encryptedBin, forKey: .encryptedBin)
        try container.encode(supportedBrands.map { $0.rawValue }, forKey: .supportedBrands)
    }
    
    private enum CodingKeys: String, CodingKey {
        case clientKey
        case encryptedBin
        case supportedBrands
    }
}
