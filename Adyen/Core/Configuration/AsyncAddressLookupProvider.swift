//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Internal adapter that bridges async closures to the AddressLookupProvider protocol
package final class AsyncAddressLookupProvider: AddressLookupProvider {
    
    private let lookupHandler: (String) async -> [AddressLookupResult]
    private let addressSelectedHandler: ((AddressLookupResult) async throws -> PostalAddress)?
    
    package init(
        onLookup: @escaping (String) async -> [AddressLookupResult],
        onAddressSelected: ((AddressLookupResult) async throws -> PostalAddress)? = nil
    ) {
        self.lookupHandler = onLookup
        self.addressSelectedHandler = onAddressSelected
    }
    
    package func lookUp(
        searchTerm: String,
        resultHandler: @escaping ([AddressLookupResult]) -> Void
    ) {
        Task {
            let results = await lookupHandler(searchTerm)
            resultHandler(results)
        }
    }
    
    package func complete(
        incompleteAddress: AddressLookupResult,
        resultHandler: @escaping (Result<PostalAddress, Error>) -> Void
    ) {
        guard let addressSelectedHandler else {
            resultHandler(.success(incompleteAddress.postalAddress))
            return
        }
        
        Task {
            do {
                let result = try await addressSelectedHandler(incompleteAddress)
                resultHandler(.success(result))
            } catch {
                resultHandler(.failure(error))
            }
        }
    }
}
