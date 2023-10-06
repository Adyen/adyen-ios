//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Contacts

/// Example implementation of an address lookup provider with debouncing and cancelling previous calls
public class DemoAddressLookupProvider: AddressLookupProvider {
    
    private let minDebounceDelay: TimeInterval = 0.3
    private let artificialNetworkCallDelay: TimeInterval = 0.5
    
    private var searchTask: DispatchWorkItem? {
        willSet {
            completionTask?.cancel()
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
    
    private var completionTask: DispatchWorkItem? {
        willSet {
            completionTask?.cancel()
            searchTask?.cancel()
        }
        didSet {
            guard let completionTask else { return }
            DispatchQueue.main.async(execute: completionTask)
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
    
    // Optional implementation to fetch the full address for an incomplete version
    public func complete(incompleteAddress: LookupAddressModel, resultHandler: @escaping (Result<PostalAddress, Error>) -> Void) {
        
        var dispatchWorkItem: DispatchWorkItem?
        
        dispatchWorkItem = DispatchWorkItem { [weak self] in
            
            guard let self else { return }
            
            /*
             Perform network request /
             Hook into address completion SDKs
             */
            
            let dummyAddress = self.addressCompletion(for: incompleteAddress.identifier)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.artificialNetworkCallDelay) {
                guard let dispatchWorkItem, !dispatchWorkItem.isCancelled else {
                    return // Bailing out if the task was cancelled
                }
                
                if let address = dummyAddress {
                    resultHandler(.success(address))
                } else {
                    resultHandler(.failure(URLError(.fileDoesNotExist)))
                }
            }
        }
        
        completionTask = dispatchWorkItem!
    }
}

// MARK: - Convenience

private extension DemoAddressLookupProvider {
    
    func searchTask(
        for searchTerm: String,
        completion: @escaping ([LookupAddressModel]) -> Void
    ) -> DispatchWorkItem {
        
        var dispatchWorkItem: DispatchWorkItem?
        
        dispatchWorkItem = DispatchWorkItem { [weak self] in
            
            guard let self else { return }
            
            /*
             Perform network request /
             Hook into address completion SDKs
             */
            
            let dummyAddresses = self.dummyAddresses(for: searchTerm)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.artificialNetworkCallDelay) {
                guard let dispatchWorkItem, !dispatchWorkItem.isCancelled else {
                    return // Bailing out if the task was cancelled
                }
                
                completion(dummyAddresses.map { .init(identifier: $0.postalCode ?? "", postalAddress: $0) })
            }
        }
        
        return dispatchWorkItem!
    }
}

// MARK: - Dummy Data

private extension DemoAddressLookupProvider {
    
    func dummyAddresses(for searchTerm: String) -> [PostalAddress] {
        [
            PostalAddress(
                city: "New York",
                country: "US",
                houseNumberOrName: nil,
                postalCode: "10019",
                stateOrProvince: "NY",
                street: "8th Ave",
                apartment: nil
            ),
            PostalAddress(
                city: "Cheyenne",
                country: "US",
                houseNumberOrName: nil,
                postalCode: "82003",
                stateOrProvince: "WY",
                street: "1280 Thorn Street",
                apartment: nil
            ),
            PostalAddress(
                city: "Amsterdam",
                country: "NL",
                houseNumberOrName: "123",
                postalCode: "1234AB",
                stateOrProvince: "Noord Holland",
                street: "Singel",
                apartment: "4"
            ),
            PostalAddress(
                city: "Random City",
                street: "Incomplete Address"
            )
        ].filter { $0.formatted.range(of: searchTerm, options: .caseInsensitive) != nil }
    }
    
    func addressCompletion(for identifier: String) -> PostalAddress? {
        // TODO: Actually implement something useful
        dummyAddresses(for: identifier).first
    }
}

private extension PostalAddress {
    
    var formatted: String {
        let address = CNMutablePostalAddress()
        city.map { address.city = $0 }
        country.map {
            address.isoCountryCode = $0
        }
        stateOrProvince.map { address.state = $0 }
        postalCode.map { address.postalCode = $0 }
        address.street = [street, houseNumberOrName, apartment]
            .compactMap { $0 }
            .joined(separator: " ")
        
        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
    }
}
