//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct BACSDirectDebitData: Equatable {
    let holderName: String
    let bankAccountNumber: String
    let bankLocationId: String
    let shopperEmail: String
}
