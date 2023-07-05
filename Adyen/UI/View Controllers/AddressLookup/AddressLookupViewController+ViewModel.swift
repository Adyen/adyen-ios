//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

// TODO: TESTS

@_spi(AdyenInternal)
public extension AddressLookupViewController {
    
    // TODO: Alex - Documentation
    
    typealias LookupProvider = (_ searchTerm: String, _ resultProvider: @escaping ([PostalAddress]) -> Void) -> Void
    
    struct ViewModel {
        
        internal enum InterfaceState: Equatable {
            case form(prefillAddress: PostalAddress?)
            case search
        }
        
        internal let style: FormComponentStyle
        internal let localizationParameters: LocalizationParameters?
        internal let supportedCountryCodes: [String]?
        
        private let lookupProvider: LookupProvider
        private let completionHandler: (PostalAddress?) -> Void
        
        internal private(set) var initialCountry: String
        
        @AdyenObservable(nil)
        internal private(set) var prefillAddress: PostalAddress?
        
        @AdyenObservable(InterfaceState.form(prefillAddress: nil))
        internal var interfaceState: InterfaceState
        
        /// Flag to indicate if the address lookup should be dismissed when search is cancelled
        ///
        /// Context: We show the search immediately when no address to prefill is provided
        /// and cancelling from this state should dismiss the whole flow.
        
        @AdyenObservable(false)
        private var shouldDismissOnSearchDismissal: Bool
        
        public init(
            style: FormComponentStyle,
            localizationParameters: LocalizationParameters?,
            supportedCountryCodes: [String]?,
            initialCountry: String,
            prefillAddress: PostalAddress? = nil,
            lookupProvider: @escaping LookupProvider,
            completionHandler: @escaping (PostalAddress?) -> Void
        ) {
            self.style = style
            self.localizationParameters = localizationParameters
            self.supportedCountryCodes = supportedCountryCodes
            self.lookupProvider = lookupProvider
            self.completionHandler = completionHandler
            self.initialCountry = initialCountry
            self.prefillAddress = prefillAddress
        }
        
        internal func handleViewDidLoad() {
            shouldDismissOnSearchDismissal = (prefillAddress == nil)
            
            if let prefillAddress {
                interfaceState = .form(prefillAddress: prefillAddress)
            } else {
                interfaceState = .search
            }
        }
        
        internal func handleShowSearchTapped(currentInput: PostalAddress) {
            prefillAddress = currentInput
            interfaceState = .search
        }
        
        internal func handleSwitchToManualEntryTapped() {
            handleShowForm(with: prefillAddress)
        }
        
        internal func handleDismissSearchTapped() {
            if shouldDismissOnSearchDismissal { return completionHandler(nil) }
            handleShowForm(with: prefillAddress)
        }
        
        internal func handleDismissAddressLookupTapped() {
            completionHandler(nil)
        }
        
        internal func lookUp(searchTerm: String, resultHandler: @escaping ([ListItem]) -> Void) {
            lookupProvider(searchTerm) { results in
                resultHandler(results.compactMap(listItem(for:)))
            }
        }
        
        internal func handleSubmit(address: PostalAddress) {
            completionHandler(address)
        }
    }
}

private extension AddressLookupViewController.ViewModel {
    
    func handleShowForm(with address: PostalAddress?) {
        interfaceState = .form(prefillAddress: address)
        shouldDismissOnSearchDismissal = false
    }
    
    func listItem(for address: PostalAddress) -> ListItem? {
        guard !address.isEmpty else { return nil }
        
        let formattedStreet = address.formattedStreet
        let formattedLocation = address.formattedLocation(using: localizationParameters)
        
        let title = !formattedStreet.isEmpty ? formattedStreet : formattedLocation
        let subtitle = !formattedStreet.isEmpty ? formattedLocation : nil
        
        return .init(
            title: title,
            subtitle: subtitle
        ) {
            self.handleShowForm(with: address)
        }
    }
}
