//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct OpenInvoiceAddress: Decodable {
    var street: String?
    var houseNumber: String?
    var city: String?
    var postalCode: String?
    var country: String?
    
    func formatted() -> String {
        return "\(street ?? "") \(houseNumber ?? "")\n\(postalCode ?? "") \(city ?? ""), \(country ?? "")"
    }
    
    private enum CodingKeys: String, CodingKey {
        case houseNumber = "houseNumberOrName"
        case street, city, postalCode, country
    }
}
