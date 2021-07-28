//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import AdyenNetworking

/// :nodoc:
internal struct BinLookupResponse: Response {
    
    /// :nodoc:
    internal typealias ErrorType = APIError

    /// :nodoc:
    internal var brands: [CardBrand]?

    /// :nodoc:
    internal let requestId: String

    /// :nodoc:
    internal let issuingCountryCode: String?

    /// :nodoc:
    internal init(brands: [CardBrand]? = nil,
                  requestId: String = UUID().uuidString,
                  issuingCountryCode: String? = "NL") {
        self.brands = brands
        self.requestId = requestId
        self.issuingCountryCode = issuingCountryCode
    }
    
    private enum CodingKeys: String, CodingKey {
        case brands,
             requestId,
             issuingCountryCode
    }
}
