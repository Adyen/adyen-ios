//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SearchViewController {
    
    /// The view model for the `SearchViewController`
    public struct ViewModel {

        public typealias ResultProvider = (_ searchTerm: String, _ handler: @escaping ([ListItem]) -> Void) -> Void
        
        internal let localizationParameters: LocalizationParameters?
        internal let style: ViewStyle
        internal let searchBarPlaceholder: String
        internal let shouldFocusSearchBarOnAppearance: Bool
        
        private let resultProvider: ResultProvider
        
        @AdyenObservable(InterfaceState.empty(searchTerm: ""))
        internal var interfaceState: InterfaceState
        
        /// Initializes a`SearchViewController.ViewModel`.
        ///
        /// - Parameters:
        ///   - localizationParameters: The localization parameters.
        ///   - style: The style of the view.
        ///   - searchBarPlaceholder: The placeholder for the search bar. Defaults to the default `.searchPlaceholder` when `nil`.
        ///   - shouldFocusSearchBarOnAppearance: Whether to focus the search bar on viewWillAppear.
        ///   - resultProvider: A closure to provide result list items for a search term.
        public init(
            localizationParameters: LocalizationParameters? = nil,
            style: ViewStyle,
            searchBarPlaceholder: String? = nil,
            shouldFocusSearchBarOnAppearance: Bool = false,
            resultProvider: @escaping ResultProvider
        ) {
            self.localizationParameters = localizationParameters
            self.style = style
            self.searchBarPlaceholder = searchBarPlaceholder ?? localizedString(.searchPlaceholder, localizationParameters)
            self.shouldFocusSearchBarOnAppearance = shouldFocusSearchBarOnAppearance
            self.resultProvider = resultProvider
        }
        
        internal func handleViewDidLoad() {
            lookUp(searchText: "")
        }
        
        internal func handleSearchTextDidChange(_ searchText: String) {
            lookUp(searchText: searchText)
        }
    }
}

private extension SearchViewController.ViewModel {
    
    func lookUp(searchText: String) {
        interfaceState = .loading
        
        resultProvider(searchText) { results in
            
            if !results.isEmpty {
                self.interfaceState = .showingResults(results: results)
                return
            }
            
            self.interfaceState = .empty(searchTerm: searchText)
        }
    }
}
