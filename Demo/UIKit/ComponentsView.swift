//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class ComponentsView: UIView {
    
    internal init() {
        super.init(frame: .zero)
        
        addSubview(tableView)
        
        tableView.adyen.anchore(inside: self)
    }
    
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Items
    
    internal var items = [[ComponentsItem]]()
    
    // MARK: - Table View
    
    private lazy var tableView: UITableView = {
        var tableViewStyle = UITableView.Style.grouped
        if #available(iOS 13.0, *) {
            tableViewStyle = .insetGrouped
        }
        
        let tableView = UITableView(frame: .zero, style: tableViewStyle)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 56.0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        return tableView
    }()
    
}

extension ComponentsView: UITableViewDataSource {
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        cell.textLabel?.text = items[indexPath.section][indexPath.item].title
        
        return cell
    }
    
}

extension ComponentsView: UITableViewDelegate {
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.section][indexPath.item].selectionHandler?()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
