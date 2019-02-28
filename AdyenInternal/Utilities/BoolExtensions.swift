//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Bool {
    func stringValue() -> String? {
        return self ? "true" : "false"
    }
}
