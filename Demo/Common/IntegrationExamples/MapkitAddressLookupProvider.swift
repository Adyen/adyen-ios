//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenUI
import Contacts
import Foundation
import MapKit

/// Example implementation of an address lookup provider with debouncing and cancelling previous calls
@MainActor
internal class MapkitAddressLookupProvider {

    internal init() {}

    private let minDebounceDelay: TimeInterval = 0.3
    
    /// Bumped whenever a new search replaces the previous one; stale in-flight lookups check it before completing.
    private var searchGeneration = 0
    
    private var searchTask: DispatchWorkItem? {
        willSet {
            searchTask?.cancel()
            
            // Invalidating any in-flight search when no new task replaces it
            if newValue == nil {
                searchGeneration += 1
            }
        }
        didSet {
            guard let searchTask else { return }
            
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + minDebounceDelay,
                execute: searchTask
            )
        }
    }
    
    internal func lookUp(searchTerm: String, resultHandler: @escaping @Sendable ([AddressLookupResult]) -> Void) {

        // Nil-ing out the last search task which also cancels the previous task if applicable
        searchTask = nil
        
        if searchTerm.isEmpty {
            
            /*
             An empty list results in an empty state to be shown.
             
             Instead of providing an empty list this could be an option
             to provide last used / saved user addresses
             */
            
            resultHandler([])
            return
        }
        
        searchTask = searchTask(for: searchTerm, completion: resultHandler)
    }
    
    func searchAsync(_ searchTerm: String) async -> [AddressLookupResult] {
        await withCheckedContinuation { continuation in
            lookUp(searchTerm: searchTerm) { results in
                continuation.resume(returning: results)
            }
        }
    }
}

// MARK: - Convenience

private extension MapkitAddressLookupProvider {
    
    func searchTask(
        for searchTerm: String,
        completion: @escaping @Sendable ([AddressLookupResult]) -> Void
    ) -> DispatchWorkItem {
        
        searchGeneration += 1
        let generation = searchGeneration
        
        return DispatchWorkItem { [weak self] in
            
            /*
             Perform network request /
             Hook into address completion SDKs
             */
            
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchTerm

            let search = MKLocalSearch(request: searchRequest)
            search.start { response, _ in
                Task { @MainActor [weak self] in
                    guard self?.searchGeneration == generation else {
                        return // Bailing out if the task was cancelled
                    }
                    
                    guard let response else {
                        // Handle the error.
                        completion([])
                        return
                    }
                    
                    let addresses: [AddressLookupResult] = response.mapItems.map {
                        .init(
                            identifier: UUID().uuidString,
                            postalAddress: .init(
                                city: $0.placemark.locality,
                                country: $0.placemark.countryCode,
                                houseNumberOrName: $0.placemark.subThoroughfare,
                                postalCode: $0.placemark.postalCode,
                                stateOrProvince: $0.placemark.administrativeArea,
                                street: $0.placemark.thoroughfare,
                                apartment: nil
                            )
                        )
                    }
                    
                    completion(addresses)
                }
            }
        }
    }
}
