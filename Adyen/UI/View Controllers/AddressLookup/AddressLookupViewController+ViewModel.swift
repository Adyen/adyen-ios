//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public extension AddressLookupViewController {
    
    /// Defining the currently active screen
    internal enum InterfaceState: Equatable {
        case form(prefillAddress: PostalAddress?)
        case search
    }
    
    /// The view model for the ``AddressLookupViewController``
    struct ViewModel {
        
        internal let style: AddressLookupStyle
        internal let localizationParameters: LocalizationParameters?
        internal let supportedCountryCodes: [String]?
        internal let initialCountry: String
        
        internal let lookupProvider: AddressLookupProvider
        private let completionHandler: (PostalAddress?) -> Void
        
        internal let addressType: FormAddressPickerItem.AddressType
        
        @AdyenObservable(nil)
        internal private(set) var prefillAddress: PostalAddress?
        
        /// The interface state defines the currently active screen.
        @AdyenObservable(InterfaceState.form(prefillAddress: nil))
        internal var interfaceState: InterfaceState
        
        /// Flag to indicate if the address lookup should be dismissed when search is cancelled
        ///
        /// Context: We show the search immediately when no address to prefill is provided
        /// and cancelling from this state should dismiss the whole flow.
        @AdyenObservable(false)
        internal var shouldDismissOnSearchDismissal: Bool
        
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
            for addressType: FormAddressPickerItem.AddressType,
            style: AddressLookupStyle = .init(),
            localizationParameters: LocalizationParameters?,
            supportedCountryCodes: [String]?,
            initialCountry: String,
            prefillAddress: PostalAddress? = nil,
            lookupProvider: AddressLookupProvider,
            completionHandler: @escaping (PostalAddress?) -> Void
        ) {
            self.addressType = addressType
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
    
    internal func handleShowForm(with address: PostalAddress?) {
        interfaceState = .form(prefillAddress: address)
        shouldDismissOnSearchDismissal = false
    }
    
    private func setInitialInterfaceState() {
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
        if shouldDismissOnSearchDismissal {
            handleDismissAddressLookup()
        } else {
            handleSwitchToManualEntryTapped()
        }
    }
    
    internal func handleAddressInputFormCompletion(validAddress: PostalAddress?) {
        completionHandler(validAddress)
    }
    
    private func handleDismissAddressLookup() {
        completionHandler(nil)
    }
}
