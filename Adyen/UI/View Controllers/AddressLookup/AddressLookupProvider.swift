//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A wrapper around ``PostalAddress`` that allows specifying an identifier
public struct LookupAddressModel {
    
    /// The specified identifier to identify a lookup address
    public let identifier: String
    /// The underlying postal address
    public let postalAddress: PostalAddress
    
    public init(
        identifier: String,
        postalAddress: PostalAddress
    ) {
        self.identifier = identifier
        self.postalAddress = postalAddress
    }
}

public protocol AddressLookupProvider: AnyObject {
    
    /// Provides a list of ``LookupAddressModel`` based on a `searchTerm`
    ///
    /// - Parameters:
    ///   - searchTerm: The entered search term to find addresses for
    ///   - resultHandler: A closure that provides a list of ``LookupAddressModel``
    func lookUp(
        searchTerm: String,
        resultHandler: @escaping (_ result: [LookupAddressModel]) -> Void
    )
    
    /// Provides a complete ``PostalAddress`` for an incomplete ``LookupAddressModel``
    ///
    /// - Parameters:
    ///   - incompleteAddress: An (potentially) incomplete ``LookupAddressModel`` to complete
    ///   - resultHandler: A closure providing a complete ``PostalAddress``
    func complete(
        incompleteAddress: LookupAddressModel,
        resultHandler: @escaping (_ result: Result<PostalAddress, Error>) -> Void
    )
}

extension AddressLookupProvider {
    
    /// Default implementation that makes the protocol function optional
    ///
    /// Immediately calls the `resultHandler` with the `incompleteAddress`
    public func complete(
        incompleteAddress: LookupAddressModel,
        resultHandler: @escaping (_ result: Result<PostalAddress, Error>) -> Void
    ) {
        resultHandler(.success(incompleteAddress.postalAddress))
    }
}
