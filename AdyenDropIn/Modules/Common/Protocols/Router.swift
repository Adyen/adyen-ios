//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol Router: AnyObject {
    var childRouter: Router? { get }
    var rootViewController: UIViewController { get }
    func stopLoading()
}

extension Router {
    internal func stopLoading() { /* Optional implementation */ }
    
    internal var latestChildRouter: Router {
        childRouter?.latestChildRouter ?? self
    }
}
