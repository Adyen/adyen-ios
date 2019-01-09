//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class ListCell: UITableViewCell {
    internal override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(itemView)
        
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal
    
    internal var item: ListItem? {
        didSet {
            itemView.title = item?.title ?? ""
            itemView.subtitle = item?.subtitle ?? ""
            itemView.imageURL = item?.imageURL
            resetAccessoryView()
            
            accessibilityLabel = item?.accessibilityLabel ?? item?.title
        }
    }
    
    internal var titleAttributes: [NSAttributedString.Key: Any]? {
        didSet {
            itemView.titleAttributes = titleAttributes
        }
    }
    
    internal var isEnabled = true {
        didSet {
            let opacity: Float = isEnabled ? 1.0 : 0.3
            layer.opacity = opacity
        }
    }
    
    internal var activityIndicatorColor: UIColor?
    
    internal var disclosureIndicatorColor: UIColor? {
        didSet {
            disclosureImageView.tintColor = disclosureIndicatorColor
            
            let renderingMode: UIImage.RenderingMode = disclosureIndicatorColor == nil ? .alwaysOriginal : .alwaysTemplate
            // If the color is nil, then use the original image, which is grey, rather than applying a color.
            // If the mode is left as .alwaysTemplate, it will pick up cell's tint colour.
            if disclosureImageView.image?.renderingMode != renderingMode {
                let disclosure = disclosureImageView.image?.withRenderingMode(renderingMode)
                disclosureImageView.image = disclosure
            }
        }
    }
    
    internal func showLoadingIndicator(_ show: Bool) {
        DispatchQueue.main.async {
            if show {
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                if let activityIndicatorColor = self.activityIndicatorColor {
                    activityIndicator.color = activityIndicatorColor
                }
                activityIndicator.startAnimating()
                self.accessoryView = activityIndicator
            } else {
                self.resetAccessoryView()
            }
        }
    }
    
    // MARK: - Private
    
    private lazy var itemView: ListItemView = {
        let itemView = ListItemView()
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        return itemView
    }()
    
    private lazy var disclosureImageView: UIImageView = {
        let disclosure = UIImage.bundleImage("cell_disclosure_indicator")
        return UIImageView(image: disclosure)
    }()
    
    private func resetAccessoryView() {
        accessoryView = item?.showsDisclosureIndicator == true ? disclosureImageView : nil
    }
    
    private func configureConstraints() {
        let marginsGuide = contentView.layoutMarginsGuide
        
        let constraints = [
            itemView.topAnchor.constraint(equalTo: marginsGuide.topAnchor),
            itemView.leadingAnchor.constraint(equalTo: marginsGuide.leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: marginsGuide.trailingAnchor),
            itemView.bottomAnchor.constraint(equalTo: marginsGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        let heightConstraint = itemView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0)
        heightConstraint.priority = .defaultLow // Silence autolayout warnings.
        heightConstraint.isActive = true
    }
    
}
