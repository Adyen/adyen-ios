//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// Displays a list from which items can be selected.
package final class ListViewController: UITableViewController {

    /// Indicates the list view controller UI style.
    package let style: ViewStyle

    /// Delegate to handle different viewController events.
    package weak var delegate: ViewControllerDelegate?
    
    /// Initializes the list view controller.
    ///
    /// - Parameter style: The UI style.
    package init(style: ViewStyle) {
        self.style = style
        super.init(style: .grouped)
    }
    
    @available(*, unavailable)
    package required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data Source
    
    package var sections: [ListSection] { dataSource.sections }
    
    private lazy var dataSource: ListViewControllerDataSource = {
        if #available(iOS 13, *) {
            return DiffableListDataSource(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, _ in
                self?.dataSource.cell(for: tableView, at: indexPath)
            })
        } else {
            return CoreListDataSource()
        }
    }()
    
    package func reload(newSections: [ListSection], animated: Bool = false) {
        dataSource.sections.flatMap(\.items).forEach { $0.loadingHandler = nil }
        
        dataSource.reload(newSections: newSections, tableView: tableView, animated: animated)

        stopLoading()

        newSections.flatMap(\.items).forEach { item in
            item.loadingHandler = { [weak self] in self?.handleItem($1, isLoading: $0) }
        }
    }
    
    private func handleItem(_ item: ListItem, isLoading: Bool) {
        if isLoading {
            startLoading(for: item)
        } else {
            stopLoading()
        }
    }
    
    package func deleteItem(at indexPath: IndexPath, animated: Bool = true) {
        dataSource.deleteItem(at: indexPath, tableView: tableView, animated: animated)
    }
    
    // MARK: - View
    
    override package func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = style.backgroundColor
        tableView.backgroundColor = style.backgroundColor
        tableView.backgroundView?.backgroundColor = style.backgroundColor
        tableView.isOpaque = false
        
        tableView.separatorColor = .clear
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = 0.0
        tableView.estimatedRowHeight = 56.0
        tableView.register(ListCell.self, forCellReuseIdentifier: dataSource.cellReuseIdentifier)
        tableView.register(ListHeaderView.self, forHeaderFooterViewReuseIdentifier: ListHeaderView.reuseIdentifier)
        tableView.dataSource = dataSource
        tableView.keyboardDismissMode = .onDrag

        delegate?.viewDidLoad(viewController: self)
    }

    override package func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(viewController: self)
    }
    
    override package func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.viewWillAppear(viewController: self)
    }
    
    // MARK: - UITableViewDelegate
    
    override package func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerItem = sections[section].header else { return nil }
        
        let headerView: ListHeaderView
        
        let reuseIdentifier = ListHeaderView.reuseIdentifier
        
        if let dequeuedView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? ListHeaderView {
            headerView = dequeuedView
        } else {
            headerView = ListHeaderView(reuseIdentifier: reuseIdentifier)
        }
        
        headerView.headerItem = headerItem

        headerView.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: "Adyen.ListViewController",
            postfix: "headerView.\(section)"
        )
        headerView.onTrailingButtonTap = { [weak self, weak headerView] in
            self?.toggleEditingMode(headerView)
        }

        return headerView
    }
    
    private func toggleEditingMode(_ headerView: ListHeaderView?) {
        var isEditingModeOn = tableView.isEditing
        isEditingModeOn.toggle()
        headerView?.isEditing = isEditingModeOn
        tableView.setEditing(isEditingModeOn, animated: true)
    }

    override package func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = sections[section].footer else {
            return nil
        }
        let footerView = ListFooterView(title: footer.title, style: footer.style)
        footerView.accessibilityIdentifier = ViewIdentifierBuilder.build(
            scopeInstance: "Adyen.ListViewController",
            postfix: "footerView.\(section)"
        )
        return footerView
    }

    override package func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        sections[section].footer == nil ? 0 : 55
    }
    
    override package func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        sections[section].header == nil ? 0 : 44.0
    }
    
    override package func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.item]
        item.selectionHandler?()
    }
    
    override package func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        sections[indexPath.section].header?.editingStyle.tableViewEditingStyle ?? .none
    }
    
    // MARK: - Item Loading state
    
    /// Starts a loading animation for a given ListItem.
    ///
    /// - Parameter item: The item to be shown as loading.
    private func startLoading(for item: ListItem) {
        dataSource.startLoading(for: item, tableView)
    }
    
    /// Stops all loading animations.
    package func stopLoading() {
        dataSource.stopLoading(tableView)
    }
}

extension EditingStyle {
    internal var tableViewEditingStyle: UITableViewCell.EditingStyle {
        switch self {
        case .delete:
            return .delete
        case .none:
            return .none
        }
    }
}
