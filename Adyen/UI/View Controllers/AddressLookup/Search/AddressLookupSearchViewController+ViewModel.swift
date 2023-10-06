//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension AddressLookupSearchViewController {
    
    struct ViewModel {
        
        internal let localizationParameters: LocalizationParameters?
        internal let style: AddressLookupSearchStyle
        
        private let lookupProvider: AddressLookupProvider
        
        private let presentationHandler: (UIViewController) -> Void
        private let showFormHandler: (PostalAddress?) -> Void
        private let switchToManualEntryHandler: () -> Void
        private let cancellationHandler: () -> Void
        
        /// Initializes the address lookup search
        ///
        /// - Parameters:
        ///   - style: The style of the view.
        ///   - localizationParameters: The localization parameters
        ///   - delegate: The delegate conforming to ``AddressLookupSearchDelegate``
        ///
        ///
        internal init(
            localizationParameters: LocalizationParameters?,
            style: AddressLookupSearchStyle,
            lookupProvider: AddressLookupProvider,
            presentationHandler: @escaping (UIViewController) -> Void,
            showFormHandler: @escaping (PostalAddress?) -> Void,
            switchToManualEntryHandler: @escaping () -> Void,
            cancellationHandler: @escaping () -> Void
        ) {
            self.localizationParameters = localizationParameters
            self.style = style
            self.lookupProvider = lookupProvider
            
            self.presentationHandler = presentationHandler
            self.showFormHandler = showFormHandler
            self.switchToManualEntryHandler = switchToManualEntryHandler
            self.cancellationHandler = cancellationHandler
        }
        
        internal func handleCancel() {
            cancellationHandler()
        }
        
        internal func handleSwitchToManualEntry() {
            switchToManualEntryHandler()
        }
        
        internal func handleLookUp(searchTerm: String, resultHandler: @escaping (([ListItem]) -> Void)) {
            
            lookupProvider.lookUp(searchTerm: searchTerm) { result in
                
                let listItems = result.compactMap(listItem(for:))
                guard !listItems.isEmpty else { return resultHandler([]) }
                resultHandler([manualEntryListItem] + listItems)
            }
        }
        
        internal func handleDidSelect(item: ListItem, addressModel: LookupAddressModel) {
            item.startLoading()
            
            lookupProvider.complete(incompleteAddress: addressModel) { [weak item] result in
                item?.stopLoading()
                
                switch result {
                case let .success(address):
                    self.handleShowForm(with: address)
                case let .failure(error):
                    self.handleShowError(error)
                }
            }
        }
        
        internal func handleShowForm(with address: PostalAddress?) {
            showFormHandler(address)
        }
        
        internal func handleShowError(_ error: Error) {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(.init(title: "Retry", style: .default))
            presentationHandler(alert)
        }
    }
}

private extension AddressLookupSearchViewController.ViewModel {
    
    var manualEntryListItem: ListItem {
        
        .init(
            title: localizedString(.addressLookupSearchManualEntryItemTitle, localizationParameters),
            style: style.manualEntryListItem
        ) {
            self.switchToManualEntryHandler()
        }
    }
    
    func listItem(for addressModel: LookupAddressModel) -> ListItem? {
        
        let address = addressModel.postalAddress
        
        guard !address.isEmpty else { return nil }
        
        let formattedStreet = address.formattedStreet
        let formattedLocation = address.formattedLocation(using: localizationParameters)
        
        let title = !formattedStreet.isEmpty ? formattedStreet : formattedLocation
        let subtitle = !formattedStreet.isEmpty ? formattedLocation : nil
        
        let listItem = ListItem(title: title, subtitle: subtitle)
        
        listItem.selectionHandler = { [weak listItem] in
            guard let listItem else { return }
            self.handleDidSelect(item: listItem, addressModel: addressModel)
        }
        
        return listItem
    }
}
