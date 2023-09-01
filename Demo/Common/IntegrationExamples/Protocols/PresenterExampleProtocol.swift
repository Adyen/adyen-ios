//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

protocol PresenterExampleProtocol: AnyObject {

    func present(viewController: UIViewController, completion: (() -> Void)?)

    func showLoadingIndicator()
    
    func hideLoadingIndicator()
    
    func dismiss(completion: (() -> Void)?)

    func presentAlert(withTitle title: String, message: String?)

    func presentAlert(with error: Error, retryHandler: (() -> Void)?)
}
