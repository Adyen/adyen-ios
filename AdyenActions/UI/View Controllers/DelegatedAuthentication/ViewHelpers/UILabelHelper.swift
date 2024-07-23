//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

extension UILabel {
    convenience init(style: TextStyle, accessibilityPostfix: String, multiline: Bool = false, scopeInstance: Any) {
        self.init(style: style)
        self.isAccessibilityElement = false
        self.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: scopeInstance, postfix: accessibilityPostfix)
        self.translatesAutoresizingMaskIntoConstraints = false
        if multiline {
            self.numberOfLines = 0
        }
    }
}
