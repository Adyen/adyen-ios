//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import PassKit
import UIKit

final class ComponentsView: UIView {
    
    init() {
        super.init(frame: .zero)
        
        addSubview(tableView)
        
        tableView.adyen.anchor(inside: self)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Items
    
    var items = [[ComponentsItem]]()
    
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
    
    // MARK: - Apple Pay
    
    @objc fileprivate func onApplePayButtonTap() {
        items.flatMap { $0 }
            .filter(\.isApplePay)
            .first
            .map { $0.selectionHandler() }
    }
    
    private func setUpApplePayCell(_ cell: UITableViewCell) {
        let style: PKPaymentButtonStyle
        if #available(iOS 14.0, *) {
            style = .automatic
        } else if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            style = .white
        } else {
            style = .black
        }
        
        let contentView = cell.contentView
        
        let payButton = PKPaymentButton(paymentButtonType: .plain, paymentButtonStyle: style)
        contentView.addSubview(payButton)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            payButton.heightAnchor.constraint(equalToConstant: 48.0),
            payButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            payButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
            payButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        payButton.addTarget(self, action: #selector(onApplePayButtonTap), for: .touchUpInside)
    }
}

extension ComponentsView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = items[indexPath.section][indexPath.row]
        if item.isApplePay == false {
            cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
            cell.textLabel?.adjustsFontForContentSizeCategory = true
            cell.textLabel?.text = items[indexPath.section][indexPath.item].title
        } else {
            setUpApplePayCell(cell)
        }
        
        return cell
    }
    
}

extension ComponentsView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.section][indexPath.item].selectionHandler()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
