//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension AbstractPersonalInformationComponent: LoadingComponent, TrackableComponent {

    /// :nodoc:
    public func stopLoading() {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    /// :nodoc:
    internal func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        let details = createPaymentDetails()
        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
    }
}

/// :nodoc:
public enum PersonalInformation: Equatable {
    case firstName
    case lastName
    case email
    case phone
    case custom(FormItemInjector)

    public static func == (lhs: PersonalInformation, rhs: PersonalInformation) -> Bool {
        switch (lhs, rhs) {
        case (.firstName, .firstName),
             (.lastName, .lastName),
             (.email, .email),
             (.phone, .phone),
             (.custom, .custom):
            return true
        default:
            return false
        }
    }
}

/// :nodoc:
extension AbstractPersonalInformationComponent {

    /// :nodoc:
    public struct Configuration {

        /// :nodoc:
        public let fields: [PersonalInformation]

        /// :nodoc:
        public init(fields: [PersonalInformation]) {
            self.fields = fields
        }
    }
}
