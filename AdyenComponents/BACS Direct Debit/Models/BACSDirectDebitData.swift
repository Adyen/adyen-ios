//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct BACSDirectDebitData: Equatable {
    internal let holderName: String
    internal let bankAccountNumber: String
    internal let bankLocationId: String
    internal let shopperEmail: String
}
