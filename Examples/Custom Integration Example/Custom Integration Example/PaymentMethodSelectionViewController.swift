//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

class PaymentMethodSelectionViewController: CheckoutViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Object Lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdatePaymentMethods), name: PaymentRequestManager.didUpdatePaymentMethodsNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = "checkout"
        navigationBar.buttonType = .dismiss(target: self, action: #selector(close))
        
        var tableViewFrame = view.bounds
        tableViewFrame.origin.y = navigationBar.frame.maxY
        tableView.frame = tableViewFrame
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        // We may need to conditionally enable scroll based on whether or not all
        // the payment methods fit on screen, but so far this is sufficient.
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        
        var loadingFrame = tableViewFrame
        loadingFrame.size.height = 310.0
        loadingIndicatorContainer.frame = loadingFrame
        view.addSubview(loadingIndicatorContainer)
        
        tableView.separatorColor = Theme.headerFooterBackgroundColor
        
        preferredContentSize = CGSize(width: view.bounds.width, height: 0.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePreferredContentSize()
        
        if !tableView.isHidden {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = request else {
            return
        }
        
        let selected = paymentMethods[indexPath.row]
        if let extraDetails = PaymentDetailsViewControllerFactory.viewController(forPaymentMethod: selected, paymentController: controller) {
            navigationController?.pushViewController(extraDetails, animated: false)
        } else {
            // For now, we only support PayPal
            if selected.type == "paypal" {
                let confirmation = PaymentConfirmationViewController(withPaymentMethod: selected, paymentController: controller)
                navigationController?.pushViewController(confirmation, animated: false)
            } else {
                let alert = UIAlertController(title: "Oops", message: "Sorry, this payment method is not supported by this demo application.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Theme.headerFooterHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel(frame: .zero)
        headerLabel.text = "Select your preferred payment method"
        headerLabel.font = Theme.standardFontSmall
        headerLabel.textAlignment = .center
        headerLabel.textColor = Theme.standardTextColor
        headerLabel.backgroundColor = Theme.headerFooterBackgroundColor
        return headerLabel
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "MethodCell"
        let cell: UITableViewCell
        
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
            cell.textLabel?.textColor = Theme.secondaryColor
            cell.backgroundColor = UIColor.white
        }
        
        let paymentMethod = paymentMethods[indexPath.row]
        cell.textLabel?.text = paymentMethod.name
        cell.imageView?.image = nil
        
        if let logoURL = paymentMethod.logoURL {
            PaymentMethodImageCache.shared.retrieveCellIcon(from: logoURL, completionHandler: { image in
                cell.imageView?.image = image
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
            })
        }
        return cell
    }
    
    // MARK: - Private
    
    private var loadingIndicatorContainer: UIView = {
        let containerFrame = CGRect(x: 0, y: 0, width: 0, height: 129.0)
        let container = UIView(frame: containerFrame)
        container.backgroundColor = Theme.headerFooterBackgroundColor
        let loadingIndicator = LoadingIndicatorView.defaultLoadingIndicator()
        var indicatorFrame = container.bounds
        indicatorFrame.size = loadingIndicator.bounds.size
        indicatorFrame.origin.y = containerFrame.height / 2 - indicatorFrame.height / 2
        indicatorFrame.origin.x = containerFrame.width / 2 - indicatorFrame.width / 2
        loadingIndicator.frame = indicatorFrame
        loadingIndicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        loadingIndicator.start()
        container.addSubview(loadingIndicator)
        return container
    }()
    
    private var tableView = UITableView(frame: .zero)
    private var request: PaymentController?
    private var paymentMethods: [PaymentMethod] = []
    private let rowHeight: CGFloat = 70.0
    
    private func updatePreferredContentSize() {
        var newPreferredContentSize = preferredContentSize
        if tableView.isHidden {
            newPreferredContentSize.height = 214.0
        } else {
            newPreferredContentSize.height = (CGFloat(paymentMethods.count) + 1) * rowHeight + tableView.frame.minY
        }
        preferredContentSize = newPreferredContentSize
        navigationController?.preferredContentSize = newPreferredContentSize
    }
    
    @objc private func didUpdatePaymentMethods() {
        // Delay is put in so that the loading indicator does not flash.
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + DispatchTimeInterval.seconds(1))) {
            self.paymentMethods = PaymentRequestManager.shared.paymentMethods?.other ?? []
            self.request = PaymentRequestManager.shared.paymentController
            self.loadingIndicatorContainer.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
            self.updatePreferredContentSize()
        }
    }
    
}
