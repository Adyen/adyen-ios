//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for MB Way payments.
public final class MBWayComponent: PhoneBasedPaymentComponent {
    
    /// :nodoc:
    private let mbWayPaymentMethod: MBWayPaymentMethod
    
    /// Initializes the MB Way component.
    ///
    /// - Parameter paymentMethod: The MB Way payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: MBWayPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.mbWayPaymentMethod = paymentMethod
        super.init(paymentMethod: paymentMethod, style: style)
    }

    override internal func getPhoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: PhoneNumberPaymentMethod.mbWay)
        return PhoneExtensionsRepository.get(with: query)
    }

    override internal func createPaymentDetails() -> PaymentMethodDetails {
        MBWayDetails(paymentMethod: paymentMethod,
                     telephoneNumber: phoneNumberItem.phoneNumber)
    }
}
