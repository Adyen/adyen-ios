//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// Contains the details supplied by the UPI component.
public struct UPIComponentDetails: PaymentMethodDetails {

    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?

    ///  Selected flow type
    public let type: String

    ///  The entered virtual payment address
    public let virtualPaymentAddress: String?

    /// Initializes the UPI Component Details.
    /// - Parameters:
    ///   - type: UPI flow type.
    ///   - virtualPaymentAddress: Virtual payment address entered by user.
    public init(type: String,
                virtualPaymentAddress: String? = nil) {
        self.type = type
        self.virtualPaymentAddress = virtualPaymentAddress
    }

}
