//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

internal struct ComponentsSection {

    internal var header: ListSectionHeader?

    internal var components: [PaymentComponent]

    internal var footer: ListSectionFooter?
}
