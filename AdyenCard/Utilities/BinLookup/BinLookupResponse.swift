//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
internal struct BinLookupResponse: Response {

    /// :nodoc:
    internal var brands: [CardBrand]?

    /// :nodoc:
    internal let requestId: String

    /// :nodoc:
    internal let issuingCountryCode: String?

    /// :nodoc:
    internal let showSocialSecurityNumber: Bool?

    /// :nodoc:
    internal let showExpiryDate: Bool?

    /// :nodoc:
    internal let supported: Bool?

    /// :nodoc:
    internal let enableLuhnCheck: Bool?

    /// :nodoc:
    internal init(brands: [CardBrand]? = nil,
                  requestId: String = UUID().uuidString,
                  issuingCountryCode: String? = "NL",
                  showSocialSecurityNumber: Bool? = nil,
                  showExpiryDate: Bool? = nil,
                  supported: Bool? = nil,
                  enableLuhnCheck: Bool? = nil) {
        self.brands = brands
        self.requestId = requestId
        self.issuingCountryCode = issuingCountryCode
        self.showSocialSecurityNumber = showSocialSecurityNumber
        self.showExpiryDate = showExpiryDate
        self.supported = supported
        self.enableLuhnCheck = enableLuhnCheck
    }
    
    private enum CodingKeys: String, CodingKey {
        case brands,
             requestId,
             issuingCountryCode,
             showSocialSecurityNumber,
             showExpiryDate,
             supported,
             enableLuhnCheck
    }
}
