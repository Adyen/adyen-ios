//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Validates email addresses.
/// :nodoc:
public class EmailValidator: RegularExpressionValidator {
    
    public init() {
        // Regex constructed according to the definition of an email address
        // https://en.wikipedia.org/wiki/Email_address
        // swiftlint:disable:next line_length
        let regex = #"^(([^<>\(\)\[\]\\.,;:\s@"]+(\.[^<>\(\)\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$"#
        super.init(regularExpression: regex, minimumLength: 6, maximumLength: 320)
    }
    
}
