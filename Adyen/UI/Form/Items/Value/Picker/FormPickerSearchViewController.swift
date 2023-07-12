//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public final class FormPickerSearchViewController<ValueType: FormPickable>: UINavigationController {
    
    public init(
        localizationParameters: LocalizationParameters? = nil,
        style: ViewStyle,
        title: String?,
        options: [ValueType],
        selectionHandler: @escaping (ValueType) -> Void
    ) {
        var updatedStyle = style
        updatedStyle.backgroundColor = .Adyen.componentBackground // TODO: Allow to pass this through
        
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: localizationParameters,
            style: updatedStyle,
            searchBarPlaceholder: nil,
            shouldFocusSearchBarOnAppearance: false
        ) { searchTerm, handler in
            
            let results = options
                .filter { $0.matches(searchTerm: searchTerm) }
                .map { $0.toListItem(with: selectionHandler) }
            
            handler(results)
        }
        
        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: FormPickerEmptyView()
        )
        
        searchViewController.title = title
        
        super.init(rootViewController: searchViewController)
        
        searchViewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissTapped)
        )
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func dismissTapped() {
        self.dismiss(animated: true)
    }
}

private extension FormPickable {
    
    func toListItem(with selectionHandler: @escaping (Self) -> Void) -> ListItem {
        .init(
            title: displayTitle,
            subtitle: displaySubtitle,
            identifier: identifier,
            selectionHandler: { selectionHandler(self) }
        )
    }
    
    func matches(searchTerm: String) -> Bool {
        if searchTerm.isEmpty { return true }
        
        if identifier.range(of: searchTerm, options: .caseInsensitive) != nil { return true }
        if displayTitle.range(of: searchTerm, options: .caseInsensitive) != nil { return true }
        
        guard let subtitle = displaySubtitle else { return false }
        return subtitle.range(of: searchTerm, options: .caseInsensitive) != nil
    }
}

// TODO: Build a better empty view

private class FormPickerEmptyView: UILabel, SearchResultsEmptyView {
    
    internal var searchTerm: String = "" {
        didSet {
            textAlignment = .center
            numberOfLines = 0
            text = "No results for '\(searchTerm)'"
        }
    }
}
