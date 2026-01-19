//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package struct AdyenAttributes: Equatable {
    package var cornerRadius: CGFloat

    internal init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }

    internal static let `default` = AdyenAttributes(cornerRadius: AdyenUIConstants.defaultCornerRadius)
}
