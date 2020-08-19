//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct BinLookupResponse: Response {
    public var detectedBrands: [CardType]
    
    internal init(brands: [CardType]) {
        self.detectedBrands = brands
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.detectedBrands = (try container.decode([String].self, forKey: .detectedBrands)).compactMap { CardType(rawValue: $0) }
    }
    
    private enum CodingKeys: String, CodingKey {
        case detectedBrands
        case issuingCountryCode
    }
}
