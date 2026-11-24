//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which shoppers can view and download the document after payment.
public struct DocumentAction: Decodable, Downloadable {
    
    /// URL of the downloadable mandate.
    public let downloadUrl: URL
    
    /// Payment method type string.
    public let paymentMethodType: PaymentMethodType
    
    private enum CodingKeys: String, CodingKey {
        case downloadUrl = "url"
        case paymentMethodType
    }
}
