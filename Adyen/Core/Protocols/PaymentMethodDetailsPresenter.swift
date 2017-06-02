//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

protocol PaymentMethodDetailsPresenter {
    func setup(with hostViewController: UIViewController, paymentRequest: PaymentRequest, paymentDetails: PaymentDetails, completion: @escaping (PaymentDetails) -> Void)
    func present()
    func dismiss(animated: Bool, completion: @escaping () -> Void)
}
