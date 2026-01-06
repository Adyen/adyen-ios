//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import UIKit

extension UIImageView {
    convenience init(infoImageStyle: ImageStyle) {
        self.init(style: infoImageStyle)
        self.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "infoImage")
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate(
            [
                self.widthAnchor.constraint(equalToConstant: 16),
                self.heightAnchor.constraint(equalToConstant: 16)
            ]
        )
    }
}
