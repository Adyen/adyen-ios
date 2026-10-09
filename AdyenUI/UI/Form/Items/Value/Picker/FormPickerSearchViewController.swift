//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

private enum FormPickerLayout {
    static let horizontalInset: CGFloat = 16
    static let searchTextFieldToResultsSpacing: CGFloat = 24
    static let listItemSpacing: CGFloat = 12
    static let listItemTitleSubtitleSpacing: CGFloat = 2
    static let listItemContentInsets = UIEdgeInsets(
        top: 12,
        left: 14,
        bottom: 12,
        right: 14
    )
}

package final class FormPickerSearchViewController<Option: FormPickable>: UINavigationController {
    
    package convenience init(
        style: Style = .init(),
        configuration: FormPickerConfiguration,
        theme: CheckoutTheme = .default,
        options: [Option],
        selectedOption: Option? = nil,
        selectionHandler: @escaping (Option) -> Void
    ) {
        self.init(
            localizationParameters: nil,
            style: style,
            configuration: configuration,
            theme: theme,
            options: options,
            selectedOption: selectedOption,
            selectionHandler: selectionHandler
        )
    }

    package init(
        localizationParameters: LocalizationParameters? = nil,
        style: Style = .init(),
        configuration: FormPickerConfiguration,
        theme: CheckoutTheme = .default,
        options: [Option],
        selectedOption: Option? = nil,
        selectionHandler: @escaping (Option) -> Void
    ) {
        let selectedOptionIdentifier = selectedOption?.identifier
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: localizationParameters,
            style: style,
            searchBarPlaceholder: nil,
            shouldShowSearchBar: configuration.isSearchEnabled,
            shouldFocusSearchBarOnAppearance: configuration.isSearchEnabled
        ) { searchTerm, handler in
            
            let results = options
                .filter { $0.matches(searchTerm: searchTerm) }
                .map {
                    $0.toListItem(
                        isSelected: $0.identifier == selectedOptionIdentifier,
                        theme: theme,
                        selectionHandler: selectionHandler
                    )
                }
            
            handler(results)
        }
        
        // An in-content header is only rendered when a subtitle is provided;
        // otherwise the title is shown in the navigation bar.
        let headerView: UIView? = configuration.subtitle == nil
            ? nil
            : FormPickerHeaderView(configuration: configuration, theme: theme)

        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: EmptyView(),
            headerView: headerView,
            resultsHorizontalInset: FormPickerLayout.horizontalInset,
            searchTextFieldToResultsSpacing: FormPickerLayout.searchTextFieldToResultsSpacing
        )

        if headerView == nil {
            searchViewController.title = configuration.title
        }
        
        super.init(rootViewController: searchViewController)
        searchViewController.resultsListViewController.sectionSpacing = FormPickerLayout.listItemSpacing

        configureSearchField(in: searchViewController, style: theme.elements.textField)
        
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
    
    private func configureSearchField(
        in viewController: SearchViewController,
        style: AdyenTextFieldStyle
    ) {
        let searchBar = viewController.searchBar
        let searchTextField = searchBar.searchTextField

        searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchTextField.applyPickerStyle(style)
        viewController.searchBarEditingStateDidChange = { [weak searchTextField] isEditing in
            searchTextField?.adyen.applyLayerBorderColor(
                isEditing ? style.borderActiveColor : style.borderColor
            )
        }
    }

    @objc
    private func dismissTapped() {
        self.dismiss(animated: true)
    }
}

private extension UISearchTextField {

    func applyPickerStyle(_ style: AdyenTextFieldStyle) {
        backgroundColor = style.containerColor
        clipsToBounds = true
        layer.borderWidth = style.borderWidth
        adyen.applyLayerBorderColor(style.borderColor)
        adyen.round(using: style.cornerRadius)
    }
}

// MARK: - FormPickable Convenience

private extension FormPickable {

    func toListItem(
        isSelected: Bool,
        theme: CheckoutTheme,
        selectionHandler: @escaping (Self) -> Void
    ) -> ListItem {
        var style = ListItemStyle()
        style.title.font = theme.elements.labels.bodyEmphasized.font
        style.title.color = theme.colors.primary
        style.subtitle.font = theme.elements.labels.subheadline.font
        style.subtitle.color = theme.colors.textSecondary

        if isSelected {
            style.backgroundColor = theme.colors.container
        }
        style.contentInsets = FormPickerLayout.listItemContentInsets
        style.titleSubtitleSpacing = FormPickerLayout.listItemTitleSubtitleSpacing

        return ListItem(
            title: title,
            subtitle: subtitle,
            icon: listItemIcon,
            trailingInfo: trailingText.map { .text($0) },
            style: style,
            identifier: identifier,
            isSelected: isSelected,
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
