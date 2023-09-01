//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public extension AddressLookupViewController {
    
    typealias LookupProvider = (_ searchTerm: String, _ resultProvider: @escaping ([PostalAddress]) -> Void) -> Void
    
    /// Defining the currently active screen
    internal enum InterfaceState: Equatable {
        case form(prefillAddress: PostalAddress?)
        case search
    }
    
    /// The view model for the ``AddressLookupViewController``
    struct ViewModel {
        
        let style: AddressLookupStyle
        let localizationParameters: LocalizationParameters?
        let supportedCountryCodes: [String]?
        let initialCountry: String
        
        private let lookupProvider: LookupProvider
        private let completionHandler: (PostalAddress?) -> Void
        
        @AdyenObservable(nil)
        private(set) var prefillAddress: PostalAddress?
        
        /// The interface state defines the currently active screen.
        @AdyenObservable(InterfaceState.form(prefillAddress: nil))
        var interfaceState: InterfaceState
        
        /// Flag to indicate if the address lookup should be dismissed when search is cancelled
        ///
        /// Context: We show the search immediately when no address to prefill is provided
        /// and cancelling from this state should dismiss the whole flow.
        @AdyenObservable(false)
        var shouldDismissOnSearchDismissal: Bool
        
        /// Initializes a ``AddressLookupViewController``
        ///
        /// - Parameters:
        ///   - style: The form style.
        ///   - localizationParameters: The localization parameters.
        ///   - supportedCountryCodes: Supported country codes. If `nil`, all country codes are listed.
        ///   - initialCountry: The initially selected country.
        ///   - prefillAddress: The address to prefill the form with. If `nil` the search screen is shown on first appearance.
        ///   - lookupProvider: A closure providing addresses based on a search term
        ///   - completionHandler: A closure that takes an optional address.
        ///    It's the presenters responsibility to dismiss the viewController.
        public init(
            style: AddressLookupStyle = .init(),
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
            
            setInitialInterfaceState()
        }
    }
}

// MARK: - Internal Interface

extension AddressLookupViewController.ViewModel {
    
    private func setInitialInterfaceState() {
        shouldDismissOnSearchDismissal = (prefillAddress == nil)
        
        if let prefillAddress {
            interfaceState = .form(prefillAddress: prefillAddress)
        } else {
            interfaceState = .search
        }
    }
    
    func handleShowSearchTapped(currentInput: PostalAddress) {
        prefillAddress = currentInput
        interfaceState = .search
    }
    
    func handleSwitchToManualEntryTapped() {
        handleShowForm(with: prefillAddress)
    }
    
    func handleDismissSearchTapped() {
        if shouldDismissOnSearchDismissal {
            handleDismissAddressLookup()
        } else {
            handleSwitchToManualEntryTapped()
        }
    }
    
    func lookUp(searchTerm: String, resultHandler: @escaping ([ListItem]) -> Void) {
        lookupProvider(searchTerm) { resultHandler($0.compactMap(listItem(for:))) }
    }
    
    func handleAddressInputFormCompletion(validAddress: PostalAddress?) {
        completionHandler(validAddress)
    }
    
    private func handleDismissAddressLookup() {
        completionHandler(nil)
    }
}

// MARK: - Convenience

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
        
        return .init(title: title, subtitle: subtitle) {
            self.handleShowForm(with: address)
        }
    }
}
