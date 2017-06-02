//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class PaymentPickerViewController: LoadingTableViewController {
    fileprivate var preferredMethods = [PaymentMethod]()
    fileprivate var availableMethods = [PaymentMethod]()
    fileprivate var justSelected = false
    fileprivate var selectedIndexPath: IndexPath?
    
    var didSelectMethodCompletion: ((PaymentMethod) -> Void)?
    var didCancel: (() -> Void)?
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            action: #selector(cancelPayment)
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
        
        tableView.register(PaymentMethodTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableView.register(CheckoutHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: "header")
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func reset() {
        if let indexPath = selectedIndexPath,
            let cell = tableView.cellForRow(at: indexPath) as? PaymentMethodTableViewCell {
            justSelected = false
            selectedIndexPath = nil
            cell.stopLoadingAnimation()
        }
    }
    
    func cancelPayment() {
        didCancel?()
    }
    
    func displayMethods(preferred: [PaymentMethod]?, available: [PaymentMethod]) {
        preferredMethods = preferred ?? [PaymentMethod]()
        availableMethods = available
        
        loading = false
        tableView.reloadData()
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
        
        if justSelected {
            return
        }
        
        justSelected = true
        selectedIndexPath = indexPath
        
        let method = paymentMethod(at: indexPath)
        
        let cell = tableView.cellForRow(at: indexPath) as? LoadingTableViewCell
        if let isRedirectType = method.plugin?.isRedirectType, isRedirectType == true {
            cell?.startLoadingAnimation()
        } else {
            reset()
        }
        
        didSelectMethodCompletion?(method)
    }
}

extension PaymentPickerViewController {
    
    func showAlert(title: String?, message: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
