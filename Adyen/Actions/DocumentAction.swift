//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which shoppers can view and download the document after payment.
package struct DocumentAction: Decodable, Downloadable {
    
    /// URL of the downloadable mandate.
    package let downloadUrl: URL
    
    /// Payment method type string.
    package let paymentMethodType: PaymentMethodType
    
    private enum CodingKeys: String, CodingKey {
        case downloadUrl = "url"
        case paymentMethodType
    }
}
