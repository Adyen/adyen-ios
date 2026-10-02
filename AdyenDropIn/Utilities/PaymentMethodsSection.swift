//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import struct AdyenUI.ListSection
#endif

internal struct PaymentMethodsSection {
    internal enum Kind: Equatable {
        case paid
        case stored
        case regular
    }

    internal let kind: Kind
    internal var header: ListSectionHeader?
    internal var paymentMethods: [PaymentMethod]
}
