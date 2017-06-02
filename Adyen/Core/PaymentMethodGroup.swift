//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class PaymentMethodGroup {
    
    let type: String
    let name: String
    let data: String
    
    init(type: String, name: String, data: String) {
        self.type = type
        self.name = name
        self.data = data
    }
    
    convenience init?(info: [String: Any]) {
        
        guard
            let type = info["type"] as? String,
            let name = info["name"] as? String,
            let data = info["paymentMethodData"] as? String
        else {
            return nil
        }
        
        self.init(type: type, name: name, data: data)
    }
}
