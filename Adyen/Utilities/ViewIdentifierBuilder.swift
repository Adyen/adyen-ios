//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// :nodoc:
public enum ViewIdentifierBuilder {
    /// Builds a UIView's identifer in a standard way.
    ///
    /// - Parameters:
    ///   - scopeInstance: The instance that encapsulate the view,
    ///    it serves as a name space for the identifer, to avoid identifier collisions.
    ///   - postfix: This should uniquely identify the view inside the scope provided by the `scopeInstance`.
    public static func build(scopeInstance: Any, postfix: String) -> String {
        let scope = (scopeInstance as? UIView)?.accessibilityIdentifier ?? String(describing: scopeInstance)
        return "\(scope).\(postfix)"
    }
}
