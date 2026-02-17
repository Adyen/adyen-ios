//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import UIKit

extension UILabel {
    internal convenience init(
        style: TextStyle,
        accessibilityPostfix: String,
        multiline: Bool = false,
        textAlignment: NSTextAlignment,
        scopeInstance: Any
    ) {
        self.init(style: style)
        self.isAccessibilityElement = false
        self.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: scopeInstance, postfix: accessibilityPostfix)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textAlignment = textAlignment
        if multiline {
            self.numberOfLines = 0
        }
    }
}
