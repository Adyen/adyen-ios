//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class IdealIssuerPickerViewController: UITableViewController {
    private var justSelected = false
    private var selectedIndexPath: IndexPath?
    private var items: [InputSelectItem] = []
    private var callback: ((InputSelectItem) -> Void)?
    
    convenience init(items: [InputSelectItem], didSelectItem: @escaping ((InputSelectItem) -> Void)) {
        self.init(style: .grouped)
        self.items = items
        callback = didSelectItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.checkoutBackground
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.register(PaymentMethodTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        reset()
    }
    
    func reset() {
        if let indexPath = selectedIndexPath,
            let cell = tableView.cellForRow(at: indexPath) as? PaymentMethodTableViewCell {
            justSelected = false
            selectedIndexPath = nil
            cell.stopLoadingAnimation()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let paymentCell = cell as? PaymentMethodTableViewCell {
            paymentCell.configure(with: items[indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if justSelected {
            return
        }
        
        justSelected = true
        selectedIndexPath = indexPath
        
        if let cell = tableView.cellForRow(at: indexPath) as? PaymentMethodTableViewCell {
            cell.startLoadingAnimation()
        }
        
        callback?(items[indexPath.row])
    }
}

extension PaymentMethodTableViewCell {
    
    func configure(with item: InputSelectItem) {
        name = item.name
        logoURL = item.imageURL
        accessoryView = nil
    }
}
