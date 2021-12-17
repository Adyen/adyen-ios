//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Indicates BACS action payment methods.
public enum BACSActionPaymentMethod: String, Codable, CaseIterable {
    case bacs = "directdebit_GB"
}

/// Describes an action in which shoppers can view and
/// download the mandate PDF after paying via BACS direct debit.
public struct BACSAction: Decodable {
    
    /// URL of the downloadable mandate.
    public let downloadUrl: URL
    
    /// Payment method type string.
    public let paymentMethodType: BACSActionPaymentMethod
    
    private enum CodingKeys: String, CodingKey {
        case downloadUrl = "url"
        case paymentMethodType
    }
}
