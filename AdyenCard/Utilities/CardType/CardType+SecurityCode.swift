//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

extension CardType {
    /// Expected security code (CVC/CVV) length: 4 for Amex, 3 for any other brand.
    internal var expectedSecurityCodeLength: Int {
        self == .americanExpress ? Constants.amexLength : Constants.generalLength
    }

    fileprivate enum Constants {
        static let amexLength = 4
        static let generalLength = 3
    }
}

extension CardType? {
    /// Expected security code (CVC/CVV) length: 4 for Amex, 3 for any other or undetected brand.
    internal var expectedSecurityCodeLength: Int {
        self?.expectedSecurityCodeLength ?? CardType.Constants.generalLength
    }
}
