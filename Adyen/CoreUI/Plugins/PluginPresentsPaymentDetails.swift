//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol PluginPresentsPaymentDetails: Plugin {
    
    /// Creates and returns a details presenter for the user to enter payment details.
    ///
    /// - Parameters:
    ///   - hostViewController: The view controller to host the details presenter's interface.
    ///   - appearanceConfiguration: The configuration of the appearance.
    /// - Returns: A details presenter for the user to enter payment details.
    func newPaymentDetailsPresenter(hostViewController: UINavigationController, appearanceConfiguration: AppearanceConfiguration) -> PaymentDetailsPresenter
    
}
