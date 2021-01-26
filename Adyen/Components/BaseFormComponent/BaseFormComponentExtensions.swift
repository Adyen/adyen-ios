//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// MARK: - FormViewControllerDelegate

extension BaseFormComponent: FormViewControllerDelegate {
    /// :nodoc:
    open func viewDidLoad(formViewController: FormViewController) { /* Empty Implementation */ }

    /// :nodoc:
    open func viewDidAppear(formViewController: FormViewController) {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
    }
}

extension BaseFormComponent {

    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
        completion?()
    }

    /// :nodoc:
    internal func didSelectSubmitButton() {
        guard formViewController.validate() else { return }
        let details = createPaymentDetails(BaseFormDetails(firstName: firstNameItem?.value,
                                                           lastName: lastNameItem?.value,
                                                           emailAddress: emailItem?.value,
                                                           phonePrefix: phoneItem?.prefix,
                                                           phoneNumber: phoneItem?.value))

        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}

/// :nodoc:
public enum BaseFormField {
    case firstName(FirstNameElement)
    case lastName(LastNameElement)
    case email(EmailElement)
    case phone(PhoneElement)
}

/// :nodoc:
extension BaseFormComponent {

    /// :nodoc:
    public struct Configuration {

        /// :nodoc:
        public let fields: [BaseFormField]

        /// :nodoc:
        public init(fields: [BaseFormField]) {
            self.fields = fields
        }
    }
}
