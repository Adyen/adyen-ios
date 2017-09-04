//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension PaymentMethod {
    
    internal var displayName: String {
        if let cardInfo = self.oneClickInfo as? CardOneClickInfo {
            return "••••\u{00a0}" + cardInfo.number // \u{00a0} is used for a non-breaking space character.
        } else if let payPalInfo = self.oneClickInfo as? PayPalOneClickInfo {
            return payPalInfo.emailAddress
        }
        
        return self.name
    }
    
}
