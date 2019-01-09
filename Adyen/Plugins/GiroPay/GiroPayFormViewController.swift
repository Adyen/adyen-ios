//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

class GiroPayFormViewController: FormViewController {
    
    // MARK: - FormViewController
    
    override func pay() {
        guard let issuer = selectedIssuer else {
            return
        }
        
        super.pay()
        completion?(issuer.bic)
    }
    
    // MARK: - UIViewController
    
    init(appearance: Appearance, paymentMethod: PaymentMethod, paymentSession: PaymentSession) {
        self.paymentMethod = paymentMethod
        self.paymentSession = paymentSession
        super.init(appearance: appearance)
        
        payActionTitle = ADYLocalizedString("giropay.continueToYourBank")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = paymentMethod.name
        formView.addFormElement(searchFormSection)
    }
    
    // MARK: - Internal
    
    var completion: Completion<String>?
    
    // MARK: - Private
    
    private let paymentSession: PaymentSession
    private let paymentMethod: PaymentMethod
    
    private var selectedIssuer: GiroPayIssuer?
    
    private lazy var uiSearchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        controller.searchResultsUpdater = self
        controller.searchBar.placeholder = ADYLocalizedString("giropay.minimumLength")
        return controller
    }()
    
    private lazy var issuersTableViewController: GiroPayIssuersViewController = {
        let tableController = GiroPayIssuersViewController()
        tableController.definesPresentationContext = true
        tableController.title = paymentMethod.name
        tableController.issuerSelectionCallback = { [weak self] issuer in
            self?.didSelect(issuer: issuer)
        }
        return tableController
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    private lazy var issuerSearchController: GiroPaySearchController = {
        GiroPaySearchController(delegate: self, paymentMethod: paymentMethod, paymentSession: paymentSession)
    }()
    
    private lazy var searchNavigationController: UINavigationController = {
        let controller = UINavigationController(rootViewController: issuersTableViewController)
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            issuersTableViewController.navigationItem.searchController = uiSearchController
            
            issuersTableViewController.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            issuersTableViewController.tableView.tableHeaderView = uiSearchController.searchBar
            
            uiSearchController.searchBar.barTintColor = UIColor.white
        }
        
        return controller
    }()
    
    private lazy var searchFormSection: FormSection = {
        let formSection = FormSection()
        formSection.title = ADYLocalizedString("giropay.searchField.title")
        
        let wrapperStackView = UIStackView()
        wrapperStackView.addArrangedSubview(searchLabel)
        wrapperStackView.addArrangedSubview(issuerView)
        formSection.addFormElement(wrapperStackView)
        
        return formSection
    }()
    
    private lazy var issuerView: GiroPayIssuerView = {
        let view = GiroPayIssuerView()
        view.isHidden = true
        view.onCloseButtonTap = { [weak self] in
            self?.didRemoveIssuerSelection()
        }
        return view
    }()
    
    private lazy var searchLabel: FormLabel = {
        let label = FormLabel()
        label.textAttributes = appearance.formAttributes.placeholderAttributes
        label.text = ADYLocalizedString("giropay.minimumLength")
        label.onLabelTap = { [weak self] in
            if let navigationController = self?.searchNavigationController {
                self?.present(navigationController, animated: true)
            }
        }
        
        return label
    }()
    
    private func didSelect(issuer: GiroPayIssuer) {
        selectedIssuer = issuer
        searchLabel.isHidden = true
        issuerView.title = issuer.bankName
        issuerView.subtitle = issuer.bic + " / " + issuer.blz
        issuerView.isHidden = false
        searchNavigationController.dismiss(animated: true)
        formView.payButton.isEnabled = true
    }
    
    private func didRemoveIssuerSelection() {
        issuerView.isHidden = true
        searchLabel.isHidden = false
        formView.payButton.isEnabled = false
    }
}

extension GiroPayFormViewController: GiroPaySearchControllerDelegate {
    
    func didStartNetworkRequest() {
        issuersTableViewController.isLoading = true
    }
    
    func didFinishNetworkRequest() {
        issuersTableViewController.isLoading = false
    }
    
    func didFail(with error: Error) {
        issuersTableViewController.error = error
    }
    
    func didUpdate(with issuers: [GiroPayIssuer]) {
        issuersTableViewController.issuers = issuers
    }
}

extension GiroPayFormViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        issuerSearchController.searchString = searchController.searchBar.text ?? ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchNavigationController.dismiss(animated: true, completion: nil)
    }
}
