//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the BLIK component.
public struct BLIKDetails: PaymentMethodDetails {

    /// The payment method type.
    public let type: String

    /// The telephone number.
    public let blikCode: String

    /// Initializes the BLIK payment details.
    ///
    /// - Parameters:
    ///   - paymentMethod: The BLIK payment method.
    ///   - blikCode: The BLIK code.
    public init(paymentMethod: PaymentMethod, blikCode: String) {
        self.type = paymentMethod.type
        self.blikCode = blikCode
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case blikCode
    }

}
