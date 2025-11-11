//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal protocol Router: AnyObject {
    var childRouter: Router? { get }
    var rootViewController: UIViewController { get }
}

extension Router {
    
    internal var latestChildRouter: Router {
        childRouter?.latestChildRouter ?? self
    }
}
