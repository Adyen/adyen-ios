//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for Doku Wallet, Doku Alfamart, and Doku Indomaret  payments.
public final class DokuComponent: AbstractPersonalInformationComponent {

    /// :nodoc:
    private let dokuPaymentMethod: DokuPaymentMethod

    /// Initializes the Doku component.
    /// - Parameters:
    ///   - paymentMethod: The Doku Wallet, Doku Alfamart, or Doku Indomaret payment method.
    ///   - apiContext: The component's UI style.
    ///   - shopperInformation: The shopper's information.
    ///   - style:The component's UI style.
    public init(paymentMethod: DokuPaymentMethod,
                apiContext: APIContext,
                shopperInformation: PrefilledShopperInformation? = nil,
                style: FormComponentStyle = FormComponentStyle()) {
        self.dokuPaymentMethod = paymentMethod
        let configuration = Configuration(fields: [.firstName, .lastName, .email])
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   apiContext: apiContext,
                   shopperInformation: shopperInformation,
                   style: style)
    }

    override public func submitButtonTitle() -> String {
        localizedString(.confirmPurchase, localizationParameters)
    }

    override public func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstNameItem,
              let lastNameItem,
              let emailItem else {
            fatalError("There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        return DokuDetails(paymentMethod: paymentMethod,
                           firstName: firstNameItem.value,
                           lastName: lastNameItem.value,
                           emailAddress: emailItem.value)
    }
}
