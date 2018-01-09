//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol PluginPresentsPaymentDetails: Plugin {
    
    /// Creates and returns a details presenter for the user to enter payment details.
    ///
    /// - Parameters:
    ///   - hostViewController: The view controller to host the details presenter's interface.
    /// - Returns: A details presenter for the user to enter payment details.
    func newPaymentDetailsPresenter(hostViewController: UINavigationController) -> PaymentDetailsPresenter
    
    /// Boolean value indicating whether a disclosure indicator should be shown for the payment method of the plugin.
    var showsDisclosureIndicator: Bool { get }
    
}

extension PluginPresentsPaymentDetails {
    
    var showsDisclosureIndicator: Bool {
        return false
    }
    
}
