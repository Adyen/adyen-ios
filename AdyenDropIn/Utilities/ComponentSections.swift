//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

internal struct ComponentsSection {

    internal var header: ComponentsSectionHeader?

    internal var components: [PaymentComponent]

    internal var footer: ComponentsSectionFooter?
}

internal struct ComponentsSectionHeader {

    internal var title: String

    internal var style: ListSectionHeaderStyle
}

internal struct ComponentsSectionFooter {

    internal var title: String

    internal var style: ListSectionFooterStyle
}
