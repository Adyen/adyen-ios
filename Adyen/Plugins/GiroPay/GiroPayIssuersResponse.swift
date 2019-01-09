//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A response for a Issuers lookup.
internal struct GiroPayIssuersResponse: Response {
    internal var issuers: [GiroPayIssuer]?
    
    // MARK: - Decoding
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        issuers = try container.decode([GiroPayIssuer].self, forKey: .giroPayIssuers)
    }
    
    // MARK: - Private
    
    private enum CodingKeys: String, CodingKey {
        case giroPayIssuers
    }
}
