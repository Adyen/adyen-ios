//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import Adyen

final class ValidatorMock: Validator {

    var handleIsValid: ((_ value: String) -> Bool)?
    func isValid(_ value: String) -> Bool {
        return handleIsValid?(value) ?? true
    }

    var handleMaximumLength: ((_ value: String) -> Int)?
    func maximumLength(for value: String) -> Int {
        return handleMaximumLength?(value) ?? .max
    }
    
}
