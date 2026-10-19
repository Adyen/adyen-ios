//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

internal struct PaymentMethodsSection {
    internal enum Kind: Equatable {
        case paid
        case stored
        case regular
    }

    internal let kind: Kind
    internal var headerTitle: String?
    internal var paymentMethods: [PaymentMethod]
}
