//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A plugin that presents additional details for the shopper to fill.
/// :nodoc:
public protocol AdditionalPaymentDetailsPlugin: Plugin {
    
    /// Presents additional payment details for the shopper to fill.
    ///
    /// - Parameters:
    ///   - details: The additional details that should be filled by the shopper.
    ///   - navigationController: The navigation controller which can be used for presenting the additional details.
    ///   - appearance: The appearance which should be used to style the presented UI.
    ///   - completion: The completion to invoke when the additional details are filled.
    func present(_ details: AdditionalPaymentDetails, using navigationController: UINavigationController, appearance: Appearance, completion: @escaping Completion<Result<[PaymentDetail]>>)
    
}
