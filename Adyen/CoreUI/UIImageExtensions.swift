//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension UIImage {
    class func bundleImage(_ name: String) -> UIImage? {
        let bundle = Bundle(for: PaymentRequest.self)
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image
    }
}
