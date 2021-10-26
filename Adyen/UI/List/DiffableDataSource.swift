//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
internal final class DiffableDataSource: UITableViewDiffableDataSource<ListSection, ListItem>, ListViewControllerDataSource {
    internal var cellReuseIdentifier: String { coreDataSource.cellReuseIdentifier }
    
    internal var sections: [ListSection] {
        get { coreDataSource.sections }
        set { coreDataSource.sections = newValue }
    }
    
    private let coreDataSource = CoreDataSource()
    
    // MARK: - UITableViewDataSource
    
    /// :nodoc:
    override public func numberOfSections(in tableView: UITableView) -> Int {
        coreDataSource.numberOfSections(in: tableView)
    }
    
    /// :nodoc:
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coreDataSource.tableView(tableView, numberOfRowsInSection: section)
    }
    
    /// :nodoc:
    override public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        coreDataSource.tableView(tableView, canEditRowAt: indexPath)
    }
    
    /// :nodoc:
    override public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        coreDataSource.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
    }
    
    // MARK: - ListViewControllerDataSource
    
    internal func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        coreDataSource.cell(for: tableView, at: indexPath)
    }

    internal func reload(newSections: [ListSection], tableView: UITableView) {
        sections = newSections.filter { $0.items.isEmpty == false }
        var snapShot = NSDiffableDataSourceSnapshot<ListSection, ListItem>()
        snapShot.appendSections(sections)
        sections.forEach { snapShot.appendItems($0.items, toSection: $0) }
        apply(snapShot, animatingDifferences: true)
        
        if sections.isEditable == false {
            tableView.setEditing(false, animated: true)
        }
    }
    
    // MARK: - Item Loading state
    
    /// Starts a loading animation for a given ListItem.
    ///
    /// - Parameter item: The item to be shown as loading.
    public func startLoading(for item: ListItem, _ tableView: UITableView) {
        coreDataSource.startLoading(for: item, tableView)
    }
    
    /// Stops all loading animations.
    public func stopLoading(_ tableView: UITableView) {
        coreDataSource.stopLoading(tableView)
    }
    
}

private extension Array where Element == ListSection {
    var isEditable: Bool {
        first(where: { $0.editingStyle != .none }) != nil
    }
}
