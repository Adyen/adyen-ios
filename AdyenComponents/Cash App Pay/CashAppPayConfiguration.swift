//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Defines the configuration for Cash App Component
public protocol AnyCashAppPayConfiguration {
    
    /// The URL for Cash App to call in order to redirect back to your application.
    var redirectURL: URL { get }

    /// A reference to your system (for example, a cart or checkout identifier).
    var referenceId: String? { get }

    /// Determines whether to store this payment method.
    var storePaymentMethod: Bool { get }
    
}
