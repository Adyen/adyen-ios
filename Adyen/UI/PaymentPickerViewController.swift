//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class PaymentPickerViewController: LoadingTableViewController {
    fileprivate var preferredMethods = [PaymentMethod]()
    fileprivate var availableMethods = [PaymentMethod]()
    
    weak var delegate: PaymentPickerViewControllerDelegate?
    
    init(delegate: PaymentPickerViewControllerDelegate) {
        self.delegate = delegate
        
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Payment Methods"
        loading = true
        
        applyNavigationBarStyle()
        setupNavigationItem()
        setupTableView()
    }
    
    private func applyNavigationBarStyle() {
        guard let navigationBar = self.navigationController?.navigationBar else {
            return
        }
        
        navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18),
            NSForegroundColorAttributeName: UIColor.checkoutDark()
        ]
        
        navigationBar.tintColor = UIColor.checkoutDark()
        navigationBar.backgroundColor = UIColor.white
        navigationBar.isTranslucent = false
    }
    
    private func setupNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.bundleImage("close"),
            style: .plain,
            target: self,
            action: #selector(didSelect(cancelButtonItem:))
        )
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.checkoutBackground()
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.sectionHeaderHeight = 30
        tableView.allowsMultipleSelectionDuringEditing = false
        
        tableView.register(PaymentMethodTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.register(CheckoutHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "header")
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func reset() {
        selectedCell?.stopLoadingAnimation()
        selectedIndexPath = nil
        
        view.isUserInteractionEnabled = true
    }
    
    func didSelect(cancelButtonItem: Any) {
        delegate?.paymentPickerViewControllerDidCancel(self)
    }
    
    func displayMethods(preferred: [PaymentMethod]?, available: [PaymentMethod]) {
        preferredMethods = preferred ?? [PaymentMethod]()
        availableMethods = available
        
        loading = false
        tableView.reloadData()
    }
    
    /// Displays an activity indicator next to the selected payment method, and disable user interaction.
    /// To hide the activity indicator and reenable user interaction, call reset().
    func displayPaymentMethodActivityIndicator() {
        selectedCell?.startLoadingAnimation()
        
        view.isUserInteractionEnabled = false
    }
    
    // MARK: Cell Selection
    
    fileprivate var selectedIndexPath: IndexPath?
    
    private var selectedCell: PaymentMethodTableViewCell? {
        guard let indexPath = selectedIndexPath else {
            return nil
        }
        
        return tableView.cellForRow(at: indexPath) as? PaymentMethodTableViewCell
    }
}

extension PaymentPickerViewController {
    private func isPreferredMethodsSection(_ section: Int) -> Bool {
        return preferredMethods.count > 0 && section == 0
    }
    
    private func paymentMethod(at indexPath: IndexPath) -> PaymentMethod {
        return isPreferredMethodsSection(indexPath.section) ? preferredMethods[indexPath.row] : availableMethods[indexPath.row]
    }
    
    private func titleFor(section: Int) -> String {
        let title = isPreferredMethodsSection(section) ? "Your payment methods" : "Select other method"
        return NSLocalizedString(title, comment: "")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var count = preferredMethods.isEmpty ? 0 : 1
        count += availableMethods.isEmpty ? 0 : 1
        return count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.numberOfSections > 1 ? 50 : 30
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == tableView.numberOfSections - 1 ? 30 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleFor(section: section)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CheckoutHeaderView
        
        if preferredMethods.count > 0 {
            headerView?.title = titleFor(section: section)
        }
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section, tableView.numberOfSections) {
        case (0, 2):
            return preferredMethods.count
        case (0, 1), (1, _):
            return availableMethods.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let cell = reusableCell as? PaymentMethodTableViewCell {
            cell.configure(with: paymentMethod(at: indexPath))
        }
        
        return reusableCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndexPath = indexPath
        
        delegate?.paymentPickerViewController(self, didSelectPaymentMethod: paymentMethod(at: indexPath))
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //  Allow editing in the `Preferred` section only.
        if tableView.numberOfSections == 2 && indexPath.section == 0 {
            return true
        }
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //  Deletion is allowed only for preferred methods (section == 0).
            if indexPath.section != 0 {
                return
            }
            
            let methodIndex = indexPath.row
            if methodIndex >= preferredMethods.count {
                return
            }
            
            //  Request to delete selected payment method.
            let method = preferredMethods[methodIndex]
            delegate?.paymentPickerViewController(self, didSelectDeletePaymentMethod: method)
            
            preferredMethods.remove(at: methodIndex)
            
            let containsSingleItem = tableView.numberOfRows(inSection: indexPath.section) == 1
            if containsSingleItem {
                tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
