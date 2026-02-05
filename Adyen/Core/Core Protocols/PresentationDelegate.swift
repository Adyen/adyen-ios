//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Delegates `ViewController`'s presentation.
public protocol PresentationDelegate: AnyObject {
    
    /// Asks the delegate to present a `PresentableComponent` as the `delegate` sees fit.
    func present(component: PresentableComponent)
}
