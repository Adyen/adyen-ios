//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package protocol AddressLookupProvider: AnyObject {
    
    /// Provides a list of ``AddressLookupResult`` based on a `searchTerm`
    ///
    /// - Parameters:
    ///   - searchTerm: The entered search term to find addresses for
    ///   - resultHandler: A closure that provides a list of ``AddressLookupResult``
    func lookUp(
        searchTerm: String,
        resultHandler: @escaping (_ result: [AddressLookupResult]) -> Void
    )
    
    /// Provides a complete ``PostalAddress`` for an incomplete ``AddressLookupResult``
    ///
    /// - Parameters:
    ///   - incompleteAddress: An (potentially) incomplete ``AddressLookupResult`` to complete
    ///   - resultHandler: A closure providing a complete ``PostalAddress``
    func complete(
        incompleteAddress: AddressLookupResult,
        resultHandler: @escaping (_ result: Result<PostalAddress, Error>) -> Void
    )
}

extension AddressLookupProvider {
    
    /// Default implementation that makes the protocol function optional
    ///
    /// Immediately calls the `resultHandler` with the `incompleteAddress`
    public func complete(
        incompleteAddress: AddressLookupResult,
        resultHandler: @escaping (_ result: Result<PostalAddress, Error>) -> Void
    ) {
        resultHandler(.success(incompleteAddress.postalAddress))
    }
}
