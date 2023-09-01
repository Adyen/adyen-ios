//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension AddressInputFormViewController {
    
    public typealias ShowSearchHandler = (_ currentInput: PostalAddress) -> Void
    
    /// The view model for ``AddressInputFormViewController``
    public struct ViewModel {
        
        let supportedCountryCodes: [String]?
        let prefillAddress: PostalAddress?
        let initialCountry: String
        let style: FormComponentStyle
        let addressViewModelBuilder: AddressViewModelBuilder
        let localizationParameters: LocalizationParameters?
        
        private let showSearchHandler: ShowSearchHandler?
        private let completionHandler: (PostalAddress?) -> Void
        
        /// Initializes a view model for ``AddressInputFormViewController``
        ///
        /// - Parameters:
        ///   - style: The form style.
        ///   - localizationParameters: The localization parameters.
        ///   - initialCountry: The initially selected country.
        ///   - prefillAddress: The address to prefill the form with. If `nil` the search screen is shown on first appearance.
        ///   - supportedCountryCodes: Supported country codes. If `nil`, all country codes are listed.
        ///   - addressViewModelBuilder: A closure providing addresses based on a search term
        ///   - handleShowSearch: An optional closure that handles showing search - if provided, a search bar is shown
        ///   - completionHandler: A closure that takes an optional address.
        ///    It's the presenters responsibility to dismiss the viewController.
        public init(
            style: FormComponentStyle,
            localizationParameters: LocalizationParameters?,
            initialCountry: String,
            prefillAddress: PostalAddress?,
            supportedCountryCodes: [String]?,
            addressViewModelBuilder: AddressViewModelBuilder = DefaultAddressViewModelBuilder(),
            handleShowSearch: ShowSearchHandler?,
            completionHandler: @escaping (PostalAddress?) -> Void
        ) {
            self.style = style
            self.initialCountry = initialCountry
            self.prefillAddress = prefillAddress
            self.supportedCountryCodes = supportedCountryCodes
            self.addressViewModelBuilder = addressViewModelBuilder
            self.showSearchHandler = handleShowSearch
            self.localizationParameters = localizationParameters
            self.completionHandler = completionHandler
        }
        
        var shouldShowSearch: Bool {
            showSearchHandler != nil
        }
        
        func handleShowSearch(currentInput: PostalAddress) {
            showSearchHandler?(currentInput)
        }
        
        func handleSubmit(validAddress: PostalAddress) {
            completionHandler(validAddress)
        }
        
        func handleDismiss() {
            completionHandler(nil)
        }
    }
}
