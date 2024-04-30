//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// Describes the interface to display a field to store the payment method.
public protocol StorePaymentMethodFieldAware: AdyenSessionAware {
    var showStorePaymentMethodField: Bool? { get }
}
