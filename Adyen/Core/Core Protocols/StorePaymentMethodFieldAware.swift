//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// Describes the interface to display a field to store the payment method.
public protocol StorePaymentMethodFieldAware: AdyenSessionAware {
    var showStorePaymentMethodField: Bool? { get }
}

@_spi(AdyenInternal)
/// Describes whether it is possible to allow for session to remove stored payment methods.
public protocol SessionStoredPaymentMethodsDelegate: AdyenSessionAware, StoredPaymentMethodsDelegate {
    
    var showRemovePaymentMethodButton: Bool { get }
    
    /// Invoked when shopper wants to delete a stored payment method from the drop-in.
    ///
    /// - Parameters:
    ///   - storedPaymentMethod: The stored payment method that the user wants to disable.
    ///   - dropInComponent: The dropIn component containing the stored payment method list.
    ///   - completion: The delegate needs to call back this closure when the disabling is done,
    ///    with a boolean parameter that indicates success or failure.
    func disable(storedPaymentMethod: StoredPaymentMethod, dropInComponent: AnyDropInComponent, completion: @escaping Completion<Bool>)
}
