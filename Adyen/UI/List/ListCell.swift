//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A cell in a ListViewController.
/// :nodoc:
public final class ListCell: UITableViewCell {
    
    /// :nodoc:
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessibilityTraits = .button
        contentView.addSubview(itemView)
        
        configureConstraints()
    }
    
    /// :nodoc:
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Item
    
    /// The item displayed in the cell cell.
    public var item: ListItem? {
        didSet {
            itemView.item = item
            itemView.accessibilityIdentifier = item?.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "itemView") }
            backgroundColor = item?.style.backgroundColor
            resetAccessoryView()
        }
    }
    
    // MARK: - Internal
    
    /// Indicates if the cell is in an enabled state.
    internal var isEnabled = true {
        didSet {
            let opacity: Float = isEnabled ? 1.0 : 0.3
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: { [weak self] in
                self?.layer.opacity = opacity
            }, completion: nil)
        }
    }
    
    // MARK: - Activity Indicator
    
    private lazy var editingActivityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: activityIndicatorViewStyle)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    private lazy var editingActivityIndicatorViewConstraints = [
        editingActivityIndicatorView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        editingActivityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ]
    
    /// Indicates whether an activity indicator should be shown as an accessory.
    internal var showsActivityIndicator: Bool = false {
        didSet {
            if showsActivityIndicator {
                showActivityIndicatorView()
            } else {
                hideActivityIndicatorView()
            }
        }
    }
    
    private func showActivityIndicatorView() {
        if isEditing {
            contentView.addSubview(editingActivityIndicatorView)
            NSLayoutConstraint.activate(editingActivityIndicatorViewConstraints)
            editingActivityIndicatorView.startAnimating()
        } else {
            let activityIndicatorView = UIActivityIndicatorView(style: activityIndicatorViewStyle)
            activityIndicatorView.startAnimating()
            accessoryView = activityIndicatorView
        }
    }
    
    private func hideActivityIndicatorView() {
        if isEditing {
            editingActivityIndicatorView.removeFromSuperview()
            NSLayoutConstraint.deactivate(editingActivityIndicatorViewConstraints)
            editingActivityIndicatorView.stopAnimating()
        } else {
            resetAccessoryView()
        }
    }
    
    private func resetAccessoryView() {
        accessoryView = nil
    }
    
    private var activityIndicatorViewStyle: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .medium
        } else {
            return .gray
        }
    }
    
    // MARK: - Item View
    
    private lazy var itemView: ListItemView = {
        let itemView = ListItemView()
        itemView.translatesAutoresizingMaskIntoConstraints = false
        itemView.preservesSuperviewLayoutMargins = false
        itemView.layoutMargins = .zero
        
        return itemView
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let layoutGuide = contentView.layoutMarginsGuide
        
        let constraints = [
            itemView.topAnchor.constraint(equalTo: topAnchor),
            itemView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            itemView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.heightAnchor
                .constraint(greaterThanOrEqualToConstant: 48.0)
                .adyen.with(priority: .defaultHigh)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
