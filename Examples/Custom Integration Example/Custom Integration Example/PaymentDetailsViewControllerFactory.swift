//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

struct PaymentDetailsViewControllerFactory {
    
    static func viewController(forPaymentMethod method: PaymentMethod) -> UIViewController? {
        if method.type == "card" {
            return CardDetailsViewController(withPaymentMethod: method)
        }
        
        return nil
    }
    
}
