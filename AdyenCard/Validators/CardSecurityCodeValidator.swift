//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a card's security code.
public final class CardSecurityCodeValidator: LengthValidator {
    
    /// :nodoc:
    public init() {
        super.init(minimumLength: 3, maximumLength: 4)
    }
    
    /// :nodoc:
    public override func isValid(_ string: String) -> Bool {
        guard super.isValid(string) else {
            return false
        }
        
        let forbiddenCharacterSet = CharacterSet.decimalDigits.inverted
        return string.rangeOfCharacter(from: forbiddenCharacterSet) == nil
    }
    
}
