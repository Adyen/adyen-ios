//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Instances of conforming types present an interface to fill in payment details.
internal protocol PaymentDetailsPresenter: class {
    
    /// The delegate of the details presenter.
    weak var delegate: PaymentDetailsPresenterDelegate? { get set }
    
    /// Requests the user to enter the payment details.
    func start()
    
}

/// Instances of conforming types respond to the completion or cancellation of a payment details presenter.
internal protocol PaymentDetailsPresenterDelegate: class {
    
    /// Tells the delegate that the user has submitted the payment details.
    ///
    /// - Parameters:
    ///   - paymentDetailsPresenter: The payment details presenter in which the payment details were entered.
    ///   - paymentDetails: The filled in payment details.
    func paymentDetailsPresenter(_ paymentDetailsPresenter: PaymentDetailsPresenter, didSubmit paymentDetails: PaymentDetails)
    
}
