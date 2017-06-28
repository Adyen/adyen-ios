//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol PaymentPickerViewControllerDelegate: class {
    
    /// Called when a payment method has been selected.
    func paymentPickerViewController(_ paymentPickerViewController: PaymentPickerViewController, didSelectPaymentMethod paymentMethod: PaymentMethod)
    
    /// Called when a payment method has been picked to delete.
    func paymentPickerViewController(_ paymentPickerViewController: PaymentPickerViewController, didSelectDeletePaymentMethod paymentMethod: PaymentMethod)
    
    /// Called when the payment method selection was cancelled by the user.
    func paymentPickerViewControllerDidCancel(_ paymentPickerViewController: PaymentPickerViewController)
}
