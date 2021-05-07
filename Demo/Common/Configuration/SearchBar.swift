//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

@available(iOS 13.0.0, *)
internal struct SearchBar: UIViewRepresentable {

    @Binding private var searchString: String
    private let placeholder: String
    
    internal init(searchString: Binding<String>, placeholder: String) {
        self._searchString = searchString
        self.placeholder = placeholder
    }

    internal func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.autocapitalizationType = .none
        searchBar.searchBarStyle = .minimal
        return searchBar
    }

    internal func updateUIView(
        _ uiView: UISearchBar,
        context: UIViewRepresentableContext<SearchBar>
    ) {
        uiView.text = searchString
    }

    internal func makeCoordinator() -> SearchBar.Coordinator {
        Coordinator(text: $searchString)
    }

    internal class Coordinator: NSObject, UISearchBarDelegate {

        @Binding private var text: String

        fileprivate init(text: Binding<String>) {
            _text = text
        }

        internal func searchBar(
            _ searchBar: UISearchBar,
            textDidChange searchText: String
        ) {
            text = searchText
        }
    }
}
