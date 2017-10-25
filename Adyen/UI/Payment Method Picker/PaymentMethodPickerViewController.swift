//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The PaymentMethodPickerViewController displays a list from which a user can pick a payment method to use to complete the payment.
internal class PaymentMethodPickerViewController: UITableViewController {
    
    /// The delegate of the payment method picker view controller.
    private(set) internal weak var delegate: PaymentMethodPickerViewControllerDelegate?
    
    /// Initializes the payment method picker view controller.
    ///
    /// - Parameters:
    ///   - delegate: The delegate to inform when a payment method has been selected.
    internal init(delegate: PaymentMethodPickerViewControllerDelegate) {
        self.delegate = delegate
        
        super.init(style: .grouped)
        
        navigationItem.title = ADYLocalizedString("paymentMethods.title")
        navigationItem.leftBarButtonItem = AppearanceConfiguration.shared.cancelButtonItem(target: self, selector: #selector(didSelect(cancelButtonItem:)))
    }
    
    /// :nodoc:
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View
    
    /// :nodoc:
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        // This is needed so that the content extends under the navigation bar at all times,
        // thereby fixing any animation issues when transitioning between screens.
        // i.e. on iOS 11 transitioning from a screen with large title in navigation bar to a small,
        // results in a black bar below the navigation bar if this is removed.
        extendedLayoutIncludesOpaqueBars = true
        
        showsActivityIndicatorView = true
        
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.register(PaymentMethodTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
    }
    
    @objc private func didSelect(cancelButtonItem: Any) {
        delegate?.paymentMethodPickerViewControllerDidCancel(self)
    }
    
    // MARK: Payment Methods
    
    fileprivate var preferredMethods = [PaymentMethod]()
    fileprivate var availableMethods = [PaymentMethod]()
    
    /// Displays the given payment methods in the list.
    ///
    /// - Parameters:
    ///   - preferred: The preferred payment methods, which will be displayed at the top of the list.
    ///   - available: All other payment methods.
    internal func displayMethods(preferred: [PaymentMethod]?, available: [PaymentMethod]) {
        preferredMethods = preferred ?? [PaymentMethod]()
        availableMethods = available
        
        showsActivityIndicatorView = false
        
        reset()
        tableView.reloadData()
    }
    
    /// Displays an activity indicator next to the selected payment method, and disable user interaction.
    /// To hide the activity indicator and reenable user interaction, call reset().
    internal func displayPaymentMethodActivityIndicator() {
        selectedCell?.startLoadingAnimation()
    }
    
    /// Resets the payment method picker's cell selection and loading state.
    internal func reset() {
        selectedCell?.stopLoadingAnimation()
        selectedIndexPath = nil
    }
    
    // MARK: Cell Selection
    
    fileprivate var selectedIndexPath: IndexPath?
    
    private var selectedCell: PaymentMethodTableViewCell? {
        guard let selectedIndexPath = selectedIndexPath else {
            return nil
        }
        
        return tableView.cellForRow(at: selectedIndexPath) as? PaymentMethodTableViewCell
    }
}

extension PaymentMethodPickerViewController {
    private func isPreferredMethodsSection(_ section: Int) -> Bool {
        return preferredMethods.count > 0 && section == 0
    }
    
    private func paymentMethod(at indexPath: IndexPath) -> PaymentMethod {
        return isPreferredMethodsSection(indexPath.section) ? preferredMethods[indexPath.row] : availableMethods[indexPath.row]
    }
    
    /// :nodoc:
    public override func numberOfSections(in tableView: UITableView) -> Int {
        var count = preferredMethods.isEmpty ? 0 : 1
        count += availableMethods.isEmpty ? 0 : 1
        return count
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !preferredMethods.isEmpty else {
            return nil
        }
        
        if isPreferredMethodsSection(section) {
            return ADYLocalizedString("paymentMethods.storedMethods")
        } else {
            return ADYLocalizedString("paymentMethods.otherMethods")
        }
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section, tableView.numberOfSections) {
        case (0, 2):
            return preferredMethods.count
        case (0, 1), (1, _):
            return availableMethods.count
        default:
            return 0
        }
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let cell = reusableCell as? PaymentMethodTableViewCell {
            cell.configure(with: paymentMethod(at: indexPath))
        }
        
        return reusableCell
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard selectedCell?.isShowingLoadingIndicator != true else {
            return
        }
        
        let selected = paymentMethod(at: indexPath)
        selected.fulfilledPaymentDetails = nil
        
        selectedIndexPath = indexPath
        
        delegate?.paymentMethodPickerViewController(self, didSelectPaymentMethod: selected)
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //  Allow editing in the `Preferred` section only.
        if tableView.numberOfSections == 2 && indexPath.section == 0 {
            return true
        }
        
        return false
    }
    
    /// :nodoc:
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
            delegate?.paymentMethodPickerViewController(self, didSelectDeletePaymentMethod: method)
            
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
