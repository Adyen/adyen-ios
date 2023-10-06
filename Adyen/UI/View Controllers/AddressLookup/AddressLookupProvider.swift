//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public struct LookupAddressModel {
    
    public let identifier: String
    public let postalAddress: PostalAddress
    
    // TODO: Allow a way for the merchant to specify their own way of formatting the address
    
    public init(
        identifier: String,
        postalAddress: PostalAddress
    ) {
        self.identifier = identifier
        self.postalAddress = postalAddress
    }
}

public protocol AddressLookupProvider: AnyObject {
    
    func lookUp(
        searchTerm: String,
        resultHandler: @escaping (_ result: [LookupAddressModel]) -> Void
    )
    
    func complete(
        incompleteAddress: LookupAddressModel,
        resultHandler: @escaping (_ result: Result<PostalAddress, Error>) -> Void
    )
}

extension AddressLookupProvider {
    
    // Default implementation
    public func complete(
        incompleteAddress: LookupAddressModel,
        resultHandler: @escaping (_ result: Result<PostalAddress, Error>) -> Void
    ) {
        resultHandler(.success(incompleteAddress.postalAddress))
    }
}
