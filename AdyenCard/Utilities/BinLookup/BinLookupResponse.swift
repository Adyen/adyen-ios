//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

internal struct BinLookupResponse: Response {

    internal var brands: [CardBrand]?

    internal let requestId: String

    internal let issuingCountryCode: String?

    internal var isCreatedLocally: Bool = false
    
    internal init(brands: [CardBrand]? = nil,
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
