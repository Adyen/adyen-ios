//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

/// Displays a list of items.
internal final class ListViewController: UITableViewController {
    internal init() {
        super.init(style: .grouped)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 44.0
        tableView.estimatedRowHeight = 56.0
        tableView.register(ListCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.separatorColor = UIColor.clear
    }
    
    // MARK: - UITableViewDelegate/UITableViewDataSource
    
    internal override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    internal override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = sections[section].title else {
            return nil
        }
        
        return ListHeaderView(title: title.uppercased(), attributes: attributes.sectionTitleAttributes)
    }
    
    internal override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    internal override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ListCell else {
            fatalError("Incorrect cell dequeued.")
        }
        
        cell.item = sections[indexPath.section].items[indexPath.item]
        cell.backgroundColor = view.backgroundColor
        cell.contentView.backgroundColor = view.backgroundColor
        cell.titleAttributes = Appearance.shared.textAttributes
        
        cell.disclosureIndicatorColor = attributes.disclosureIndicatorColor
        cell.activityIndicatorColor = attributes.activityIndicatorColor ?? Appearance.shared.activityIndicatorColor ?? attributes.disclosureIndicatorColor
        
        if let selectionColor = attributes.selectionColor {
            let backgroundView = UIView()
            backgroundView.backgroundColor = selectionColor
            cell.selectedBackgroundView = backgroundView
        } else {
            cell.selectedBackgroundView = nil
        }
        
        return cell
    }
    
    internal override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.item]
        lastSelectedItem = item
        item.selectionHandler?()
    }
    
    internal override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = sections[indexPath.section].items[indexPath.item]
        return item.deletionHandler != nil
    }
    
    internal override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]
        let containsSingleItemBeforeDeletion = section.items.count == 1
        
        guard let deletionHandler = item.deletionHandler else {
            return
        }
        
        reloadDataOnSectionUpdate = false
        if containsSingleItemBeforeDeletion {
            sections.remove(at: indexPath.section)
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        } else {
            sections[indexPath.section].items.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        reloadDataOnSectionUpdate = true
        deletionHandler()
    }
    
    // MARK: - Internal
    
    internal var sections: [ListSection] = [] {
        didSet {
            // Filter out empty sections.
            let filteredSections = sections.filter({ $0.items.count > 0 })
            if filteredSections.count != sections.count {
                sections = filteredSections
            } else if reloadDataOnSectionUpdate {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Private
    
    private var attributes = Appearance.shared.listAttributes
    
    // Used to determine if table should be reloaded when sections are reset
    // or if the reload is handled elsewhere, i.e. through deletion.
    private var reloadDataOnSectionUpdate = true
    
    private var lastSelectedItem: ListItem?
    
    private var lastSelectedCell: ListCell? {
        guard let lastSelectedItem = lastSelectedItem else {
            return nil
        }
        
        for case let cell as ListCell in tableView.visibleCells where cell.item == lastSelectedItem {
            return cell
        }
        
        return nil
    }
    
}

extension ListViewController: PaymentProcessingElement {
    func startProcessing() {
        guard let lastSelectedCell = lastSelectedCell else {
            return
        }
        
        tableView.isUserInteractionEnabled = false
        lastSelectedCell.showLoadingIndicator(true)
        
        for case let cell as ListCell in tableView.visibleCells where cell.item != lastSelectedItem {
            cell.isEnabled = false
        }
    }
    
    func stopProcessing() {
        guard let lastSelectedCell = lastSelectedCell else {
            return
        }
        
        tableView.isUserInteractionEnabled = true
        lastSelectedCell.showLoadingIndicator(false)
        lastSelectedItem = nil
        
        for case let cell as ListCell in tableView.visibleCells {
            cell.isEnabled = true
        }
    }
}
