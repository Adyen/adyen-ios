//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol ListViewControllerDataSource: NSObject, UITableViewDataSource {
    
    var sections: [ListSection] { get set }
    
    var cellReuseIdentifier: String { get }
    
    func reload(newSections: [ListSection], tableView: UITableView)
    
    func deleteItem(at indexPath: IndexPath, tableView: UITableView)
    
    func cell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
    
    func startLoading(for item: ListItem, _ tableView: UITableView)
    
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
        sections[indexPath.section].editingStyle != .none
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
    
    public func reload(newSections: [ListSection], tableView: UITableView) {
        sections = newSections.filter { $0.items.count > 0 }
        tableView.reloadData()
    }
    
    public func deleteItem(at indexPath: IndexPath, tableView: UITableView) {
        sections[indexPath.section].deleteItem(index: indexPath.item)
        tableView.reloadData()
    }
    
    // MARK: - Item Loading state
    
    /// Starts a loading animation for a given ListItem.
    ///
    /// - Parameter item: The item to be shown as loading.
    public func startLoading(for item: ListItem, _ tableView: UITableView) {
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
    
    /// Stops all loading animations.
    public func stopLoading(_ tableView: UITableView) {
        tableView.isUserInteractionEnabled = true
        
        for case let visibleCell as ListCell in tableView.visibleCells {
            visibleCell.isEnabled = true
            visibleCell.showsActivityIndicator = false
        }
    }
}
