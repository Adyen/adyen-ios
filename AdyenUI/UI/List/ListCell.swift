//
// Copyright (c) 2018 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A cell in a ListViewController.
package final class ListCell: UITableViewCell {

    override package init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessibilityTraits = .button
        contentView.addSubview(itemView)
        
        configureConstraints()
    }
    
    @available(*, unavailable)
    package required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Theme

    /// The theme to use for styling.
    ///
    /// Settable rather than init-only because cells are created by `dequeueReusableCell`.
    package var theme: CheckoutTheme = .default {
        didSet {
            itemView.theme = theme
            applyTheme()
        }
    }

    private func applyTheme() {
        contentView.backgroundColor = .clear
        setNeedsUpdateConfiguration()
    }

    override package func updateConfiguration(using state: UICellConfigurationState) {
        var background = UIBackgroundConfiguration.listGroupedCell().updated(for: state)
        if !state.isHighlighted, !state.isSelected {
            background.backgroundColor = item?.isSelected == true ? theme.colors.container : theme.colors.background
        }
        background.cornerRadius = AdyenUIConstants.defaultCornerRadius
        background.backgroundInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: rowHorizontalInset,
            bottom: 0,
            trailing: rowHorizontalInset
        )
        backgroundConfiguration = background
    }

    // MARK: - Row Inset

    /// The horizontal distance between the row, including its background, and the cell edges.
    package var rowHorizontalInset: CGFloat = 0 {
        didSet {
            itemViewLeadingConstraint.constant = rowHorizontalInset
            itemViewTrailingConstraint.constant = -rowHorizontalInset
            setNeedsUpdateConfiguration()
        }
    }

    // MARK: - Item
    
    /// The item displayed in the cell cell.
    package var item: ListItem? {
        didSet {
            itemView.item = item
            itemView.accessibilityIdentifier = item?.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "itemView") }
            applyTheme()
            updateHorizontalInsets()

            resetAccessoryView()
            
            accessibilityLabel = item?.accessibilityLabel
            isAccessibilityElement = item != nil
            updateSelectedState()
        }
    }

    private func updateSelectedState() {
        accessibilityMarkAsSelected(item?.isSelected == true)
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
        .medium
    }
    
    // MARK: - Item View
    
    private lazy var itemView: ListItemView = {
        let itemView = ListItemView(theme: theme)
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        return itemView
    }()

    private lazy var itemViewLeadingConstraint = itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)

    private lazy var itemViewTrailingConstraint = itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    
    // MARK: - Layout
    
    private func updateHorizontalInsets() {
        guard let inset = item?.horizontalContentInset else {
            itemView.preservesSuperviewLayoutMargins = true
            itemView.layoutMargins = .zero
            return
        }
        
        itemView.preservesSuperviewLayoutMargins = false
        itemView.layoutMargins = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    private func configureConstraints() {
        let constraints = [
            itemView.topAnchor.constraint(equalTo: contentView.topAnchor),
            itemViewLeadingConstraint,
            itemViewTrailingConstraint,
            itemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.heightAnchor
                .constraint(greaterThanOrEqualToConstant: 48.0)
                .adyen.with(priority: .defaultHigh)
        ]
        
        NSLayoutConstraint.activate(constraints)
        updateHorizontalInsets()
    }
    
}
