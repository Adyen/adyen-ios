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
    /// - Parameters:
    ///   - paymentMethod: The MB Way payment method.
    ///   - apiContext: The component's API context.
    ///   - shopperInformation: The shopper's information.
    ///   - style: The component's UI style.
    public init(paymentMethod: MBWayPaymentMethod,
                apiContext: APIContext,
                shopperInformation: PrefilledShopperInformation? = nil,
                style: FormComponentStyle = FormComponentStyle()) {
        self.mbWayPaymentMethod = paymentMethod
        let configuration = Configuration(fields: [.phone])
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   apiContext: apiContext,
                   shopperInformation: shopperInformation,
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
        guard let phoneItem else {
            fatalError("There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        return MBWayDetails(paymentMethod: paymentMethod,
                            telephoneNumber: phoneItem.phoneNumber)
    }
}
