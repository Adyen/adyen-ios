//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Contacts
import Foundation
import MapKit

/// Example implementation of an address lookup provider with debouncing and cancelling previous calls
public class MapkitAddressLookupProvider: AddressLookupProvider {
    
    public init() {}
    
    private let minDebounceDelay: TimeInterval = 0.3
    
    private var searchTask: DispatchWorkItem? {
        willSet {
            searchTask?.cancel()
        }
        didSet {
            guard let searchTask else { return }
            
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + minDebounceDelay,
                execute: searchTask
            )
        }
    }
    
    public func lookUp(searchTerm: String, resultHandler: @escaping ([LookupAddressModel]) -> Void) {
        
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
}

// MARK: - Convenience

private extension MapkitAddressLookupProvider {
    
    func searchTask(
        for searchTerm: String,
        completion: @escaping ([LookupAddressModel]) -> Void
    ) -> DispatchWorkItem {
        
        var dispatchWorkItem: DispatchWorkItem?
        
        dispatchWorkItem = DispatchWorkItem {
            
            /*
             Perform network request /
             Hook into address completion SDKs
             */
            
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchTerm

            let search = MKLocalSearch(request: searchRequest)
            search.start { response, _ in
                
                guard let dispatchWorkItem, !dispatchWorkItem.isCancelled else {
                    return // Bailing out if the task was cancelled
                }
                
                guard let response else {
                    // Handle the error.
                    completion([])
                    return
                }
                
                let addresses: [LookupAddressModel] = response.mapItems.map {
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
        
        return dispatchWorkItem!
    }
}
