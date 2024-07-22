//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A protocol that provides control over the submission process in a payment component.
public protocol SubmitCustomizable {
    /// Submits the payment request to initiate the payment process.
    ///
    /// This method starts the payment flow in the payment component. It triggers the validation of the form associated
    /// with the payment component and initiates the loading state.
    /// Ensure that the loading state is appropriately stopped once the payment process is complete.
    ///
    /// If the `showSubmitButton` of the payment component is enabled, calling this method will have no effect and will simply return.
    ///
    /// - Important:
    ///    - Ensure that the payment component is properly configured before calling this method.
    ///    - Handle stopping the loading state after the payment process is completed.
    func submit()
}
