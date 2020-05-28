//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension String {
    
    // swiftlint:disable:next explicit_acl
    var countryFlag: String {
        guard CountryCodeValidator().isValid(self) else { return "" }
        let base = 127397
        var usv = String.UnicodeScalarView()
        self.utf16.compactMap { UnicodeScalar(base + Int($0)) }.forEach { usv.append($0) }
        return String(usv)
    }
    
}
