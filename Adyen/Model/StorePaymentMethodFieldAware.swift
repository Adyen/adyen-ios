//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// Describes the interface to display a field to store the payment method.
public protocol StorePaymentMethodFieldAware: AdyenSessionAware {
    var showStorePaymentMethodField: Bool? { get }
}

@_spi(AdyenInternal)
/// Describles whether it is possible to allow removing stored payment methods.
public protocol StoredPaymentMethodRemovable: AdyenSessionAware {
    var showRemovePaymentMethodButton: Bool { get }
}
