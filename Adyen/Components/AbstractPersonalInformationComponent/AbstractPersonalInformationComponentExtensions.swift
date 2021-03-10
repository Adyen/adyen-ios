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

        let details = createPaymentDetails()

        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}

/// :nodoc:
public enum PersonalInformation {
    case firstName
    case lastName
    case email
    case phone
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
