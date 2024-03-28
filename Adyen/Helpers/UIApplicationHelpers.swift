//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public extension AdyenScope where Base: UIApplication {
    var mainKeyWindow: UIWindow? {
        if #available(iOS 13, *) {
            return base.connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
        } else {
            return base.keyWindow
        }
    }
}
