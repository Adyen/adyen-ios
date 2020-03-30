//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

struct PaymentMethodMock: PaymentMethod {
    
    var type: String
    
    var name: String
    
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        return builder.build(paymentMethod: self)
    }
    
}
