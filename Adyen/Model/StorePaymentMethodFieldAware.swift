//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// Describes the interface to have a store payment method field.
public protocol StorePaymentMethodFieldAware: AdyenSessionAware {
    var showStorePaymentMethodField: Bool? { get }
}
