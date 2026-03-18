//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

internal struct PaymentMethodsSection {
    internal var header: ListSectionHeader?
    internal var paymentMethods: [PaymentMethod]
}
