//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes any configuration for the Twint component.
public protocol AnyTwintComponentConfiguration {
    /// Indicates if the field for storing the payment method should be displayed in the form. Defaults to `true`.
    var showsStorePaymentMethodField: Bool { get set }

    /// Determines whether to store this payment method. Defaults to `false`.
    /// Ignored if `showsStorePaymentMethodField` is `true`.
    var storePaymentMethod: Bool { get set }
}
