//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct OpenInvoicePersonalDetails {
    var firstName: String?
    var lastName: String?
    var dateOfBirth: String?
    var gender: String?
    var telephoneNumber: String?
    var socialSecurityNumber: String?
    var shopperEmail: String?
    
    func fullName() -> String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
}
