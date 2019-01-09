//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A response for a SSN lookup.
internal struct KlarnaSSNLookupResponse: Response {
    internal var name: OpenInvoiceName?
    internal var address: OpenInvoiceAddress?
    
    // MARK: - Decoding
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let addressList = try container.decode([AddressNames].self, forKey: .addressNames)
        
        address = addressList.first?.object.address
        name = addressList.first?.object.name
    }
    
    // MARK: - Private
    
    private enum CodingKeys: String, CodingKey {
        case addressNames
    }
    
    private struct AddressNames: Decodable {
        var object: AddressName
        
        private enum CodingKeys: String, CodingKey {
            case object = "AddressName"
        }
    }
    
    private struct AddressName: Decodable {
        var address: OpenInvoiceAddress
        var name: OpenInvoiceName
    }
}
