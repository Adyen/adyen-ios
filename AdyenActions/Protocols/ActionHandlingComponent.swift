//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Any component that can handle an `Action` object.
public protocol ActionHandlingComponent: Component {
    
    /// Handles an action object.
    /// - Parameters:
    ///   - action: The action object.
    func handle(_ action: Action)
    
    /// This function should be invoked from the application's delegate when the application is opened through a URL.
    ///
    /// - Parameter url: The URL through which the application was opened.
    /// - Returns: A boolean value indicating whether the URL was handled by the redirect component.
    func applicationDidOpen(from url: URL) -> Bool
}
