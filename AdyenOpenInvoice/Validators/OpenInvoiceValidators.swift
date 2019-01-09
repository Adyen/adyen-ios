//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class OpenInvoiceNameValidator: Validator {
    func isValid(_ string: String) -> Bool {
        return string.count > 0
    }
}

class KlarnaSSNValidator: NumericValidator {
    func isValid(_ string: String) -> Bool {
        return string.count > 12
    }
    
    func isMaxLength(_ string: String) -> Bool {
        return string.count >= 13
    }
    
    func format(_ string: String) -> String {
        let sanitized = sanitize(string)
        let lowerIndex = sanitized.count < 8 ? sanitized.count : 8
        let start = sanitized[0..<lowerIndex].grouped(length: 2, separator: " ")
        let end = sanitized[lowerIndex..<sanitized.count]
        return start + end
    }
}

class OpenInvoiceEmailValidator: Validator {
    func isValid(_ string: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return predicate.evaluate(with: string)
    }
}

class OpenInvoiceTelephoneNumberValidator: Validator {
    func isValid(_ string: String) -> Bool {
        let format = "^[+]*[(]{0,1}[0-9]{1,3}[)]{0,1}[-\\s\\./0-9]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", format)
        return predicate.evaluate(with: string)
    }
}
