//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

class GiroPayIssuersViewController: UITableViewController {
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.register(GiroPayIssuerTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.isHidden = false
        configureTableInformationLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Delay call to next runloop so first responder is correctly set.
        DispatchQueue.main.async { [weak self] in
            self?.searchBar?.becomeFirstResponder()
        }
    }
    
    // MARK: - Internal
    
    var error: Error? {
        didSet {
            if let error = error {
                displayInformationLabel(with: error.localizedDescription)
            }
        }
    }
    
    var issuers: [GiroPayIssuer] = [] {
        didSet {
            configureTableInformationLabel()
            tableView.reloadData()
        }
    }
    
    var isLoading = false {
        didSet {
            if isLoading {
                tableView.backgroundView = activityIndicator
                activityIndicator.startAnimating()
            }
        }
    }
    
    var issuerSelectionCallback: ((GiroPayIssuer) -> Void)?
    
    // MARK: - Private
    
    private let cellIdentifier = "issuerCellIdentifier"
    private let dynamicTypeController = DynamicTypeController()
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .gray)
    
    private lazy var informationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        dynamicTypeController.observeDynamicType(for: label, withTextAttributes: Appearance.shared.formAttributes.placeholderAttributes, textStyle: .body)
        return label
    }()
    
    private var searchBar: UISearchBar? {
        if #available(iOS 11.0, *) {
            return navigationItem.searchController?.searchBar
        } else {
            return tableView.tableHeaderView as? UISearchBar
        }
    }
    
    private func configureTableInformationLabel() {
        if let searchBarText = searchBar?.text, searchBarText.count > 3, issuers.count == 0 {
            displayInformationLabel(with: ADYLocalizedString("giropay.noResults"))
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func displayInformationLabel(with text: String) {
        informationLabel.attributedText = NSAttributedString(string: text, attributes: Appearance.shared.formAttributes.placeholderAttributes)
        tableView.backgroundView = informationLabel
    }
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issuers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? GiroPayIssuerTableViewCell
        
        let issuer = issuers[indexPath.row]
        cell?.issuerView.title = issuer.bankName
        cell?.issuerView.subtitle = issuer.bic + " / " + issuer.blz
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        issuerSelectionCallback?(issuers[indexPath.row])
    }
}

class GiroPayIssuerTableViewCell: UITableViewCell {
    
    let issuerView = GiroPayIssuerView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(issuerView)
        
        let constraints = [
            issuerView.heightAnchor.constraint(equalTo: heightAnchor),
            issuerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            issuerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
