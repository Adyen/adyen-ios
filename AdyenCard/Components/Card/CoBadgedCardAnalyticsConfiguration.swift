//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal struct CoBadgedCardAnalyticsConfiguration: AnalyticsStringDictionaryConvertible {

    private let dualBrands: String?

    internal init(dualBrands: String?) {
        self.dualBrands = dualBrands
    }
}
