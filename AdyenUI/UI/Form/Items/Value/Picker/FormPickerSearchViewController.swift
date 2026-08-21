//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

package final class FormPickerSearchViewController<Option: FormPickable>: UINavigationController {
    
    package convenience init(
        style: Style = .init(),
        title: String?,
        configuration: FormPickerConfiguration = .init(),
        theme: CheckoutTheme = .default,
        options: [Option],
        selectionHandler: @escaping (Option) -> Void
    ) {
        self.init(
            localizationParameters: nil,
            style: style,
            title: title,
            configuration: configuration,
            theme: theme,
            options: options,
            selectionHandler: selectionHandler
        )
    }

    package init(
        localizationParameters: LocalizationParameters? = nil,
        style: Style = .init(),
        title: String?,
        configuration: FormPickerConfiguration = .init(),
        theme: CheckoutTheme = .default,
        options: [Option],
        selectionHandler: @escaping (Option) -> Void
    ) {
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: localizationParameters,
            style: style,
            searchBarPlaceholder: nil,
            shouldFocusSearchBarOnAppearance: true
        ) { searchTerm, handler in
            
            let results = options
                .filter { $0.matches(searchTerm: searchTerm) }
                .map { $0.toListItem(with: selectionHandler) }
            
            handler(results)
        }
        
        let headerView = configuration.header.map { FormPickerHeaderView(header: $0, theme: theme) }

        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: EmptyView(),
            headerView: headerView
        )
        
        // When a header is shown the title lives in the header; otherwise fall back to the navigation bar title.
        if headerView == nil {
            searchViewController.title = title
        }
        
        super.init(rootViewController: searchViewController)
        
        searchViewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissTapped)
        )
    }
    
    @available(*, unavailable)
    package required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func dismissTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: FormPickerElement Convenience

private extension FormPickable {
    
    func toListItem(with selectionHandler: @escaping (Self) -> Void) -> ListItem {
        .init(
            title: title,
            subtitle: subtitle,
            icon: listItemIcon,
            trailingInfo: trailingText.map { .text($0) },
            identifier: identifier,
            selectionHandler: { selectionHandler(self) }
        )
    }
    
    func matches(searchTerm: String) -> Bool {
        if searchTerm.isEmpty {
            return true
        }
        
        if identifier.range(of: searchTerm, options: .caseInsensitive) != nil {
            return true
        }
        if title.range(of: searchTerm, options: .caseInsensitive) != nil {
            return true
        }
        
        return subtitle?.range(of: searchTerm, options: .caseInsensitive) != nil
    }
    
    private var listItemIcon: ListItem.Icon? {
        guard let icon else { return nil }
        return .init(location: .local(image: icon))
    }
}
