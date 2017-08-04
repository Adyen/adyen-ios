//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Instances conforming to the PaymentMethodPickerViewControllerDelegate can be informed of the selection or deletion of displayed payment methods.
/// All delegate methods are invoked on the main thread.
internal protocol PaymentMethodPickerViewControllerDelegate: class {
    
    /// Called when a payment method has been selected.
    func paymentMethodPickerViewController(_ paymentMethodPickerViewController: PaymentMethodPickerViewController, didSelectPaymentMethod paymentMethod: PaymentMethod)
    
    /// Called when a payment method has been picked to delete.
    func paymentMethodPickerViewController(_ paymentMethodPickerViewController: PaymentMethodPickerViewController, didSelectDeletePaymentMethod paymentMethod: PaymentMethod)
    
    /// Called when the payment method selection was cancelled by the user.
    func paymentMethodPickerViewControllerDidCancel(_ paymentMethodPickerViewController: PaymentMethodPickerViewController)
}
