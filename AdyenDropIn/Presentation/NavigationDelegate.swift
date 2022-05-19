//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Delegates `ViewController`'s dismissal.
internal protocol DismissalDelegate: AnyObject {

    /// Asks the `delegate` to dismiss itself as the `delegate` sees fit.
    func dismiss(completion: (() -> Void)?)
}

internal typealias NavigationDelegate = PresentationDelegate & DismissalDelegate
