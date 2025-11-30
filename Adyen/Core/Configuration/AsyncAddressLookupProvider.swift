//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Internal adapter that bridges async closures to the AddressLookupProvider protocol
package final class AsyncAddressLookupProvider: AddressLookupProvider {
    
    private let lookupHandler: (String) async -> [LookupAddressModel]
    private let addressSelectedHandler: ((LookupAddressModel) async throws -> PostalAddress)?
    
    package init(
        onLookup: @escaping (String) async -> [LookupAddressModel],
        onAddressSelected: ((LookupAddressModel) async throws -> PostalAddress)? = nil
    ) {
        self.lookupHandler = onLookup
        self.addressSelectedHandler = onAddressSelected
    }
    
    package func lookUp(
        searchTerm: String,
        resultHandler: @escaping ([LookupAddressModel]) -> Void
    ) {
        Task {
            let results = await lookupHandler(searchTerm)
            await callOnMainActor(resultHandler, with: results)
        }
    }
    
    package func complete(
        incompleteAddress: LookupAddressModel,
        resultHandler: @escaping (Result<PostalAddress, Error>) -> Void
    ) {
        guard let addressSelectedHandler else {
            Task {
                await callOnMainActor(resultHandler, with: .success(incompleteAddress.postalAddress))
            }
            return
        }
        
        Task {
            do {
                let result = try await addressSelectedHandler(incompleteAddress)
                await callOnMainActor(resultHandler, with: .success(result))
            } catch {
                await callOnMainActor(resultHandler, with: .failure(error))
            }
        }
    }
    
    @MainActor
    private func callOnMainActor<T>(_ handler: (T) -> Void, with value: T) {
        handler(value)
    }
}
