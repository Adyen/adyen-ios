//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

struct CardPaymentMethodMock: AnyCardPaymentMethod {

    var type: String

    var name: String

    var brands: [String]

}
