//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension SearchViewController {
    
    enum InterfaceState {
        case loading
        case empty(searchTerm: String)
        case showingResults(results: [ListItem])
    }
}

// MARK: - Equatable

extension SearchViewController.InterfaceState: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
            
        case let (.empty(lhsSearchTerm), .empty(rhsSearchTerm)):
            return lhsSearchTerm == rhsSearchTerm
            
        case let (.showingResults(lhsResults), .showingResults(rhsResults)):
            return lhsResults == rhsResults
            
        default:
            return false
        }
    }
}
