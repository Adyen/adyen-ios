//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

final class ValidatorMock: Validator {
    
    var handleIsValid: ((_ value: String) -> Bool)?
    func isValid(_ value: String) -> Bool {
        handleIsValid?(value) ?? true
    }
    
    var handleMaximumLength: ((_ value: String) -> Int)?
    func maximumLength(for value: String) -> Int {
        handleMaximumLength?(value) ?? .max
    }
    
}
