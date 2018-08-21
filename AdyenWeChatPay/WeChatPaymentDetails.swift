//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Array where Element == PaymentDetail {
    /// The payment detail for WeChat result code
    public var weChatResulCode: PaymentDetail? {
        get {
            return self[weChatResultCodeKey]
        }
        
        set {
            self[weChatResultCodeKey] = newValue
        }
    }
}

private let weChatResultCodeKey = "resultCode"
