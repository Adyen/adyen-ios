//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

extension AbstractPersonalInformationComponent: LoadingComponent {

    public func stopLoading() {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    internal func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
        do {
            let details = try createPaymentDetails()
            submit(data: PaymentComponentData(paymentMethodDetails: details,
                                              amount: payment?.amount,
                                              order: order))
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
}

@_spi(AdyenInternal)
extension AbstractPersonalInformationComponent: TrackableComponent {}

@_spi(AdyenInternal)
public enum PersonalInformation: Equatable {
    case firstName
    case lastName
    case email
    case phone
    case address
    case deliveryAddress
    case custom(FormItemInjector)

    public static func == (lhs: PersonalInformation, rhs: PersonalInformation) -> Bool {
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
