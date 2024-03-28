//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes any configuration for the Cash App Pay component.
public protocol AnyCashAppPayConfiguration {
    
    /// The URL for Cash App to call in order to redirect back to your application.
    var redirectURL: URL { get }

    /// A reference to your system (for example, a cart or checkout identifier).
    var referenceId: String? { get }

    /// Indicates if the field for storing the payment method should be displayed in the form. Defaults to `true`.
    var showsStorePaymentMethodField: Bool { get }
    
    /// Determines whether to store this payment method. Defaults to `false`.
    /// Ignored if `showsStorePaymentMethodField` is `true`.
    var storePaymentMethod: Bool { get }
}
