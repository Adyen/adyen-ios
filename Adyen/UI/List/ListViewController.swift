//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Displays a list from which items can be selected.
/// :nodoc:
public final class ListViewController: UITableViewController {
    
    /// Indicates the list view controller UI style.
    public let style: ListComponentStyle
    
    /// Initializes the list view controller.
    ///
    /// - Parameter style: The UI style.
    public init(style: ListComponentStyle = ListComponentStyle()) {
        self.style = style
        if #available(iOS 11.0, *) {
            super.init(style: .grouped)
        } else {
            super.init(style: .plain)
        }
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    public override var preferredContentSize: CGSize {
        get { tableView.contentSize }
        
        // swiftlint:disable:next unused_setter_value
        set { assertionFailure("""
        PreferredContentSize is overridden for this view controller.
        getter - returns content size of scroll view.
        setter - no implemented.
        """) }
    }
    
    // MARK: - Items
    
    /// The items displayed in the list.
    public var sections: [ListSection] = [] {
        didSet {
            // Filter out empty sections.
            let filteredSections = sections.filter { $0.items.count > 0 }
            if filteredSections.count != sections.count {
                sections = filteredSections
            } else if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Item Loading state
    
    /// Starts a loading animation for a given ListItem.
    ///
    /// - Parameter item: The item to be shown as loading.
    public func startLoading(for item: ListItem) {
        if let cell = cell(for: item) {
            cell.showsActivityIndicator = true
        }
        
        tableView.isUserInteractionEnabled = false
        
        for case let visibleCell as ListCell in tableView.visibleCells where visibleCell.item != item {
            visibleCell.isEnabled = false
        }
    }
    
    /// Stops all loading animations.
    public func stopLoading() {
        tableView.isUserInteractionEnabled = true
        
        for case let visibleCell as ListCell in tableView.visibleCells {
            visibleCell.isEnabled = true
            visibleCell.showsActivityIndicator = false
        }
    }
    
    // MARK: - View
    
    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = style.backgroundColor
        tableView.backgroundColor = style.backgroundColor
        tableView.backgroundView?.backgroundColor = style.backgroundColor
        tableView.isOpaque = false
        
        tableView.separatorColor = .clear
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = 0.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56.0
        tableView.register(ListCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    // MARK: - UITableView
    
    private let cellReuseIdentifier = "Cell"
    
    /// :nodoc:
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = sections[section].title else {
            return nil
        }
        
        let headerView = ListHeaderView(title: title, style: style.sectionHeader)
        headerView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "Adyen.ListViewController",
                                                                         postfix: "headerView.\(section)")
        
        return headerView
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].title == nil ? 0 : 44.0
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? ListCell else {
            fatalError("Failed to dequeue cell.")
        }
        
        cell.item = sections[indexPath.section].items[indexPath.row]
        
        return cell
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.item]
        item.selectionHandler?()
    }
    
    // MARK: Private
    
    private func cell(for item: ListItem) -> ListCell? {
        for case let cell as ListCell in tableView.visibleCells where cell.item == item {
            return cell
        }
        
        return nil
    }
}
