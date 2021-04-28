//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for MB Way payments.
public final class MBWayComponent: AbstractPersonalInformationComponent {
    
    /// :nodoc:
    private let mbWayPaymentMethod: MBWayPaymentMethod
    
    /// Initializes the MB Way component.
    ///
    /// - Parameter paymentMethod: The MB Way payment method.
    /// - Parameter style: The Component's UI style.
    public init(paymentMethod: MBWayPaymentMethod, style: FormComponentStyle = FormComponentStyle()) {
        self.mbWayPaymentMethod = paymentMethod
        let configuration = Configuration(fields: [.phone])
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   style: style)
    }

    override public func submitButtonTitle() -> String {
        localizedString(.continueTo, localizationParameters, paymentMethod.name)
    }

    override public func getPhoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: PhoneNumberPaymentMethod.mbWay)
        return PhoneExtensionsRepository.get(with: query)
    }

    override public func createPaymentDetails() -> PaymentMethodDetails {
        guard let phoneItem = phoneItem else {
            fatalError("There seems to be an error in the BaseFormComponent configuration.")
        }
        return MBWayDetails(paymentMethod: paymentMethod,
                            telephoneNumber: phoneItem.phoneNumber)
    }
}
