//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension PaymentMethod {
    
    internal var isCVCRequested: Bool {
        guard let cardTokenInputDetail = cardTokenInputDetail else {
            return false
        }
        
        guard let noCVCStringValue = cardTokenInputDetail.configuration?["noCVC"] as? String else {
            return true
        }
        
        let noCVC = noCVCStringValue.boolValue() ?? false
        
        return !noCVC
    }
    
    internal var isCVCOptional: Bool {
        guard let cardTokenInputDetail = cardTokenInputDetail else {
            return true
        }
        
        guard case let .cardToken(isCVCOptional) = cardTokenInputDetail.type else {
            return false
        }
        
        return isCVCOptional
    }
    
    private var cardTokenInputDetail: InputDetail? {
        return inputDetails?.first(where: { inputDetail -> Bool in
            switch inputDetail.type {
            case .cardToken:
                return true
            default:
                return false
            }
        })
    }
    
}
