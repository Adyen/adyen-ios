//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public struct AdyenAttributes: Equatable {
    public var cornerRadius: CGFloat

    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }

    public static let `default` = AdyenAttributes(cornerRadius: AdyenUIConstants.defaultCornerRadius)
}
