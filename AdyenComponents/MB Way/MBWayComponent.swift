//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for MB Way payments.
public final class MBWayComponent: BaseFormComponent {
    
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

    override public func submitButtonTitle() -> String {
        ADYLocalizedString("adyen.continueTo", localizationParameters, paymentMethod.name)
    }

    override public func createPaymentDetails(_ details: BaseFormDetails) -> PaymentMethodDetails {
        guard let phoneNumber = details.fullPhoneNumber else {
            fatalError("There seems to be an error in the BaseFormComponent configuration.")
        }
        return MBWayDetails(paymentMethod: mbWayPaymentMethod, telephoneNumber: phoneNumber)
    }

    override public func createConfiguration() -> Configuration {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "phoneNumberItem")

        let phoneElement = PhoneElement(identifier: identifier,
                                        phoneExtensions: getPhoneExtensions(),
                                        style: style.textField)
        return BaseFormComponent.Configuration(fields: [.phone(phoneElement)])
    }

    private func getPhoneExtensions() -> [PhoneExtensionPickerItem] {
        let query = PhoneExtensionsQuery(paymentMethod: PhoneNumberPaymentMethod.mbWay)
        let extensions = PhoneExtensionsRepository.get(with: query)

        return extensions.map {
            let title = "\($0.countryDisplayName) (\($0.value))"
            return PhoneExtensionPickerItem(identifier: $0.countryCode,
                                            title: title,
                                            phoneExtension: $0.value)

        }
    }
}
