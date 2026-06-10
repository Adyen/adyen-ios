//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.PaymentComponentData
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormButtonItem
#endif
import UIKit

extension AbstractPersonalInformationComponent: LoadingComponent {

    package func stopLoading() {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    internal func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
        do {
            let details = try createPaymentDetails()
            submit(data: PaymentComponentData(
                paymentMethodDetails: details,
                amount: context.amount,
                order: order
            ))
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
}

extension AbstractPersonalInformationComponent: TrackableComponent {}

package enum PersonalInformation: Equatable {
    case firstName
    case lastName
    case email
    case phone
    case address
    case deliveryAddress
    case custom(FormItemInjector)

    package static func == (lhs: PersonalInformation, rhs: PersonalInformation) -> Bool {
        switch (lhs, rhs) {
        case (.firstName, .firstName),
             (.lastName, .lastName),
             (.email, .email),
             (.phone, .phone),
             (.address, .address),
             (.deliveryAddress, .deliveryAddress),
             (.custom, .custom):
            return true
        default:
            return false
        }
    }
}
