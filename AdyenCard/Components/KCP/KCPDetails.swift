//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// The additional details for Korean Cards Payment.
public struct KCPDetails: AdditionalDetails {

    /// The date of birth of the cardholder (private card) or the Corporate registration number (corporate card).
    public let taxNumber: String

    /// The two-digit password.
    public let password: String

    /// The new instance of additional details for Korean Cards Payment.
    /// - Parameters:
    ///   - taxNumber: he corporate tax number or a person's date of birth.
    ///   - password: The two-digit password.
    public init(taxNumber: String, password: String) {
        self.taxNumber = taxNumber
        self.password = password
    }

    private enum CodingKeys: String, CodingKey {
        case taxNumber = "kcp.cardTaxno"
        case password = "kcp.cardPwd"
    }

}
