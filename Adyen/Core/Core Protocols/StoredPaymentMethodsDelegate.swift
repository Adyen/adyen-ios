//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Describes the methods a delegate of stored payment methods needs to implement.
public protocol StoredPaymentMethodsDelegate: AnyObject {

    /// Invoked when shopper wants to delete a stored payment method.
    ///
    /// - Parameters:
    ///   - storedPaymentMethod: The stored payment method that the user wants to disable.
    ///   - completion: The delegate needs to call back this closure when the disabling is done,
    ///    with a boolean parameter that indicates success or failure.
    func disable(storedPaymentMethod: StoredPaymentMethod, completion: @escaping Completion<Bool>)
}
