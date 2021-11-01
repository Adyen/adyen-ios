//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
/// A `ListViewController` data source.
internal protocol ListViewControllerDataSource: NSObject, UITableViewDataSource {
    
    /// :nodoc:
    /// All sections data.
    var sections: [ListSection] { get }
    
    /// :nodoc:
    /// Cell reuse idenitifier.
    var cellReuseIdentifier: String { get }
    
    /// :nodoc:
    /// Reloads all data.
    func reload(newSections: [ListSection], tableView: UITableView)
    
    /// :nodoc:
    /// Deletes an item at a certain `IndexPath`.
    func deleteItem(at indexPath: IndexPath, tableView: UITableView)
    
    /// :nodoc:
    /// Creates a new `UITableViewCell` at a certain `IndexPath`.
    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    
    /// :nodoc:
    /// Starts a loading animation for a given ListItem.
    func startLoading(for item: ListItem, _ tableView: UITableView)
    
    /// :nodoc:
    /// Stops all loading animations.
    func stopLoading(_ tableView: UITableView)
}

internal final class CoreDataSource: NSObject, ListViewControllerDataSource {
    
    internal var sections: [ListSection] = []
    
    internal let cellReuseIdentifier = "Cell"
    
    // MARK: - UITableViewDataSource
    
    /// :nodoc:
    internal func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    /// :nodoc:
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }
    
    /// :nodoc:
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell(for: tableView, at: indexPath)
    }
    
    /// :nodoc:
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let header = sections[indexPath.section].header else { return false }
        return header.editingStyle != .none
    }
    
    /// :nodoc:
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let item = sections[indexPath.section].items[indexPath.item]
        guard let deletionHandler = item.deletionHandler else { return }
        
        startLoading(for: item, tableView)
        
        let completion: Completion<Bool> = { [weak self] _ in
            self?.stopLoading(tableView)
        }
        
        deletionHandler(indexPath, completion)
    }
    
    // MARK: - ListViewControllerDataSource
    
    internal func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? ListCell else {
            fatalError("Failed to dequeue cell.")
        }
        
        cell.item = sections[indexPath.section].items[indexPath.row]
        
        return cell
    }
    
    internal func reload(newSections: [ListSection], tableView: UITableView) {
        sections = newSections.filter { $0.items.count > 0 }
        tableView.reloadData()
    }
    
    internal func deleteItem(at indexPath: IndexPath, tableView: UITableView) {
        sections.deleteItem(at: indexPath)
        tableView.reloadData()
    }
    
    // MARK: - Item Loading state
    
    internal func startLoading(for item: ListItem, _ tableView: UITableView) {
        if let cell = cell(for: item, tableView: tableView) {
            cell.showsActivityIndicator = true
        }
        
        tableView.isUserInteractionEnabled = false
        
        for case let visibleCell as ListCell in tableView.visibleCells where visibleCell.item != item {
            visibleCell.isEnabled = false
        }
    }
    
    private func cell(for item: ListItem, tableView: UITableView) -> ListCell? {
        for case let cell as ListCell in tableView.visibleCells where cell.item == item {
            return cell
        }
        
        return nil
    }
    
    internal func stopLoading(_ tableView: UITableView) {
        tableView.isUserInteractionEnabled = true
        
        for case let visibleCell as ListCell in tableView.visibleCells {
            visibleCell.isEnabled = true
            visibleCell.showsActivityIndicator = false
        }
    }
}
