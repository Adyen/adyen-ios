//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a phone number.
/// :nodoc:
public final class PhoneNumberValidator: RegularExpressionValidator {
    
    public init() {
        let regex = #"^[+]*[0-9]{1,4}[\s0-9]*$"#
        super.init(regularExpression: regex, minimumLength: 2, maximumLength: 20)
    }
    
}
