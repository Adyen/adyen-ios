//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal struct BinLookupResponse: Response {

    internal var brands: [CardBrand]?

    internal let requestId: String

    internal let issuingCountryCode: String
    
    private enum CodingKeys: String, CodingKey {
        case brands, requestId, issuingCountryCode
    }
}
