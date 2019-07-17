//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A cell in a ListViewController.
/// :nodoc:
public final class ListCell: UITableViewCell {
    
    /// :nodoc:
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(itemView)
        
        configureConstraints()
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    public override func prepareForReuse() {
        item = nil
    }
    
    // MARK: - Item
    
    /// The item displayed in the cell cell.
    public var item: ListItem? {
        didSet {
            itemView.item = item
            resetAccessoryView()
        }
    }
    
    // MARK: - Internal
    
    internal var isEnabled = true {
        didSet {
            let opacity: Float = isEnabled ? 1.0 : 0.3
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.layer.opacity = opacity
            }
        }
    }
    
    internal func showLoadingIndicator(_ show: Bool) {
        DispatchQueue.main.async { [weak self] in
            if show {
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.startAnimating()
                self?.accessoryView = activityIndicator
            } else {
                self?.resetAccessoryView()
            }
        }
    }
    
    internal func resetAccessoryView() {
        accessoryView = nil
        accessoryType = item?.showsDisclosureIndicator == true ? .disclosureIndicator : .none
    }
    
    // MARK: - Item View
    
    private lazy var itemView: ListItemView = {
        let itemView = ListItemView()
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        return itemView
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let layoutGuide = contentView.layoutMarginsGuide
        
        let constraints = [
            itemView.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            itemView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            itemView.trailingAnchor.constraint(lessThanOrEqualTo: layoutGuide.trailingAnchor),
            itemView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        let heightConstraint = itemView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0)
        heightConstraint.isActive = true
    }
    
}
