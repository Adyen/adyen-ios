//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

internal struct PaymentMethodsSection {

    internal let header: ListSectionHeader?

    internal let paymentMethods: [PaymentMethod]

    internal let footer: ListSectionFooter?
}
