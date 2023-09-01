//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

struct BinLookupResponse: Response {

    var brands: [CardBrand]?

    let requestId: String

    let issuingCountryCode: String?

    var isCreatedLocally: Bool = false
    
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
