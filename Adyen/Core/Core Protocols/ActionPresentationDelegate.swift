//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Delegates `ViewController`'s presentation.
@MainActor
package protocol ActionPresentationDelegate: AnyObject {

    /// Asks the delegate to present the action's `UIViewController` as the `delegate` sees fit.
    func present(actionViewController: UIViewController, actionData: ActionData)
}
