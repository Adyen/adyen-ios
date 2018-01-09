//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A list of items from which one can be selected.
internal final class PickerViewController: UITableViewController {
    
    /// The delegate of the picker view controller.
    internal weak var delegate: PickerViewControllerDelegate?
    
    /// Initializes the picker view controller.
    ///
    /// - Parameter items: The items to display in the picker view controller.
    internal init(items: [PickerItem]) {
        self.items = items
        
        super.init(style: .grouped)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Items
    
    /// The items to display in the picker view controller.
    internal var items = [PickerItem]() {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    
    private func item(at indexPath: IndexPath) -> PickerItem {
        return items[indexPath.row]
    }
    
    private func indexPath(for item: PickerItem) -> IndexPath? {
        return items.index(of: item).map { IndexPath(indexes: [0, $0]) }
    }
    
    // MARK: - Activity Indicator View
    
    /// Shows the activity indicator for a given item.
    ///
    /// - Parameter item: The item for which to show the activity indicator.
    internal func showActivityIndicator(for item: PickerItem) {
        let cell = indexPath(for: item).flatMap { tableView.cellForRow(at: $0) } as? PickerViewCell
        cell?.showsActivityIndicatorView = true
        
        view.isUserInteractionEnabled = false
    }
    
    /// Hides the activity indicator.
    internal func hideActivityIndicator() {
        for case let cell as PickerViewCell in tableView.visibleCells {
            cell.showsActivityIndicatorView = false
        }
        
        view.isUserInteractionEnabled = true
    }
    
    /// Boolean value indicating whether the activity indicator should automatically be hidden when the view appears.
    internal var hidesActivityIndicatorOnViewWillAppear = true
    
    // MARK: - View
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 56.0
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if hidesActivityIndicatorOnViewWillAppear {
            hideActivityIndicator()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    internal override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? PickerViewCell else {
            fatalError("Incorrect cell dequeued.")
        }
        
        cell.item = item(at: indexPath)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.didSelect(item(at: indexPath), in: self)
    }
    
}

/// The delegate of the picker view controller, receives a message when an item is selected.
internal protocol PickerViewControllerDelegate: AnyObject {
    
    /// Invoked by the picker view controller when an item is selected.
    ///
    /// - Parameters:
    ///   - pickerItem: The item that has been selected.
    ///   - pickerViewController: The picker view controller in which the item has been selected.
    func didSelect(_ pickerItem: PickerItem, in pickerViewController: PickerViewController)
    
}
