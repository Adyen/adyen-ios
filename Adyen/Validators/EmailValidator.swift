//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates a phone number.
/// :nodoc:
internal class EmailValidator: LengthValidator {
    
    public init() {
        super.init(minimumLength: 6, maximumLength: 320)
    }
    
    /// :nodoc:
    public override func isValid(_ value: String) -> Bool {
        guard super.isValid(value) else { return false }
        // Regex constructed according to the definition of an email address
        // https://en.wikipedia.org/wiki/Email_address
        // swiftlint:disable:next line_length
        let regex = #"^(([^<>\(\)\[\]\\.,;:\s@"]+(\.[^<>\(\)\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$"#
        guard let range = value.range(of: regex, options: .regularExpression) else { return false }
        return range == (value.startIndex..<value.endIndex)
    }
    
    /// :nodoc:
    public override func maximumLength(for value: String) -> Int {
        return Int.max
    }
    
}
