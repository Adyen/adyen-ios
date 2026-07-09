//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Delegates `ViewController`'s presentation.
@MainActor
public protocol PresentationDelegate: AnyObject {
    
    /// Asks the delegate to present a `UIViewController` as the `delegate` sees fit.
    func present(viewController: UIViewController)
}
