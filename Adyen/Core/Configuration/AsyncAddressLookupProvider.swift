//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Internal adapter that bridges ``AddressCallbacks`` to the AddressLookupProvider protocol.
///
/// Without callbacks, lookups return no results and selected addresses are used as-is.
package final class AsyncAddressLookupProvider: AddressLookupProvider {
    
    private let callbacks: AddressCallbacks?
    
    package init(callbacks: AddressCallbacks?) {
        self.callbacks = callbacks
    }
    
    package func lookUp(
        searchTerm: String,
        resultHandler: @escaping ([AddressLookupResult]) -> Void
    ) {
        Task {
            let results = await callbacks?.onAddressLookup(searchTerm) ?? []
            resultHandler(results)
        }
    }
    
    package func complete(
        incompleteAddress: AddressLookupResult,
        resultHandler: @escaping (Result<PostalAddress, Error>) -> Void
    ) {
        guard let addressSelectedHandler = callbacks?.onAddressSelected else {
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
