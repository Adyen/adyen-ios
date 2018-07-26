//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension UIImage {
    public class func bundleImage(_ name: String) -> UIImage? {
        return UIImage(named: name, in: .resources, compatibleWith: nil)
    }
}
