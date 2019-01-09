//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

enum CardFormFieldConfiguration {
    case none, optional, required
    
    static func from(paymentDetail: PaymentDetail?) -> CardFormFieldConfiguration {
        guard let detail = paymentDetail else {
            return .none
        }
        
        return detail.isOptional ? .optional : .required
    }
}
