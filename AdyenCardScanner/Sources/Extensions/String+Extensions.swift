//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension String {
    var isOnlyNumbers: Bool {
        !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
}
