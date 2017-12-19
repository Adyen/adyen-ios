//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class PickerViewCell: UITableViewCell {
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(customImageView)
        contentView.addSubview(titleLabel)
        
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func prepareForReuse() {
        super.prepareForReuse()
        
        item = nil
        showsActivityIndicatorView = false
    }
    
    // MARK: - Item
    
    /// The item to display in the cell.
    internal var item: PickerItem? {
        didSet {
            titleLabel.text = item?.title
            accessibilityLabel = item?.title
            
            if let imageURL = item?.imageURL {
                customImageView.downloadImage(from: imageURL)
            } else {
                customImageView.image = nil
            }
        }
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let marginsGuide = contentView.layoutMarginsGuide
        
        let constraints = [
            customImageView.leadingAnchor.constraint(equalTo: marginsGuide.leadingAnchor),
            customImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customImageView.widthAnchor.constraint(equalToConstant: 40.0),
            customImageView.heightAnchor.constraint(equalToConstant: 26.0),
            titleLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 20.0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: marginsGuide.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Image View
    
    private lazy var customImageView: UIImageView = {
        let customImageView = UIImageView()
        customImageView.contentMode = .scaleAspectFit
        customImageView.clipsToBounds = true
        customImageView.layer.cornerRadius = 4.0
        customImageView.layer.borderWidth = 1.0 / UIScreen.main.nativeScale
        customImageView.layer.borderColor = UIColor(white: 0.0, alpha: 0.2).cgColor
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return customImageView
    }()
    
    // MARK: - Title Label
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.textColor = UIColor.checkoutDarkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isAccessibilityElement = false
        
        return titleLabel
    }()
    
    // MARK: - Activity Indicator View
    
    /// Boolean value indicating whether or not an activity indicator view should be shown.
    internal var showsActivityIndicatorView = false {
        didSet {
            guard showsActivityIndicatorView != oldValue else { return }
            
            if showsActivityIndicatorView {
                accessoryView = activityIndicatorView
                
                activityIndicatorView.startAnimating()
            } else {
                accessoryView = nil
                
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    private lazy var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
}
