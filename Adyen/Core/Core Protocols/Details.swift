//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains details supplied by a component. These details are used to initiate or complete a payment.
public protocol Details: OpaqueEncodable {}

/// Contains the payment details entered by the user to complete payment with chosen payment method.
public protocol PaymentMethodDetails: Details {
    
    @_documentation(visibility: internal)
    var checkoutAttemptId: String? { get set }
}

public extension PaymentMethodDetails {

    /// This default implementation has to be provided to be able to build with `BUILD_LIBRARY_FOR_DISTRIBUTION` enabled
    ///
    /// - Warning: Access will cause an failure in debug mode to assure the correct implementation of the `PaymentMethodDetails` protocol
    @_documentation(visibility: internal)
    var checkoutAttemptId: String? {
        get {
            AdyenAssertion.assertionFailure(
                message: "`@_documentation(visibility: internal) var checkoutAttemptId: String?` needs to be provided on `\(String(describing: Self.self))`"
            )
            
            return "do-not-track"
        }
        // swiftlint:disable:next unused_setter_value
        set {
            AdyenAssertion.assertionFailure(
                message: "`@_documentation(visibility: internal) var checkoutAttemptId: String?` needs to be provided on `\(String(describing: Self.self))`"
            )
        }
    }
}

/// Contains additional details that were retrieved to complete a payment.
public protocol AdditionalDetails: Details {}
