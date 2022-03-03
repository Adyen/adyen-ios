//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public protocol SessionProtocol: PaymentComponentDelegate, ActionComponentDelegate, PartialPaymentDelegate {
    /// Invoked when the DropIn component fails.
    ///
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - dropInComponent: The DropIn component that failed.
    func didFail(with error: Error, from dropInComponent: Component)
}
