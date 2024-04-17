//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a numeric string.
@_spi(AdyenInternal)
open class NumericStringValidator: LengthValidator {
    
    override open func isValid(_ value: String) -> Bool {
        guard super.isValid(value) else { return false }
        return !value.contains(where: { !$0.isNumber || !$0.isASCII })
    }
    
}
