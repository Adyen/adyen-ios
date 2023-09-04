//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

/// :nodoc:
struct BinLookupResponse: Response {

    /// :nodoc:
    var brands: [CardBrand]?

    /// :nodoc:
    let requestId: String

    /// :nodoc:
    let issuingCountryCode: String?

    /// :nodoc:
    var isCreatedLocally: Bool = false
    
    /// :nodoc:
    init(brands: [CardBrand]? = nil,
         requestId: String = UUID().uuidString,
         issuingCountryCode: String? = "NL",
         isCreatedLocally: Bool = true) {
        self.brands = brands
        self.requestId = requestId
        self.issuingCountryCode = issuingCountryCode
        self.isCreatedLocally = isCreatedLocally
    }
    
    private enum CodingKeys: String, CodingKey {
        case brands,
             requestId,
             issuingCountryCode
    }
}
