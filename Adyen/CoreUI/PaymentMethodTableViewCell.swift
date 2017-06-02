//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class PaymentMethodTableViewCell: LoadingTableViewCell {
    fileprivate let nameLabel = UILabel()
    fileprivate let logoImageView = UIImageView()
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var logoURL: URL? {
        didSet {
            guard let url = logoURL else {
                logoImageView.image = nil
                return
            }
            
            logoImageView.downloadedFrom(url: url)
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.layer.cornerRadius = 4
            logoImageView.layer.borderWidth = 1 / UIScreen.main.nativeScale
            logoImageView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            logoImageView.clipsToBounds = true
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
}

// MARK: Subviews Stack

extension PaymentMethodTableViewCell {
    
    func setupViews() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(nameLabel)
        addSubview(logoImageView)
        
        applyLogoConstraints()
        applyNameConstraints()
        applyStyling()
    }
    
    func applyLogoConstraints() {
        self.addConstraint(NSLayoutConstraint(
            item: logoImageView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 40
        ))
        self.addConstraint(NSLayoutConstraint(
            item: logoImageView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 26
        ))
        self.addConstraint(NSLayoutConstraint(
            item: logoImageView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        ))
        self.addConstraint(NSLayoutConstraint(
            item: logoImageView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: 20
        ))
    }
    
    func applyNameConstraints() {
        self.addConstraint(NSLayoutConstraint(
            item: nameLabel,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        ))
        self.addConstraint(NSLayoutConstraint(
            item: nameLabel,
            attribute: .leading,
            relatedBy: .equal,
            toItem: logoImageView,
            attribute: .trailing,
            multiplier: 1,
            constant: 20
        ))
        self.addConstraint(NSLayoutConstraint(
            item: nameLabel,
            attribute: .trailing,
            relatedBy: .lessThanOrEqual,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: -35
        ))
    }
    
    func applyStyling() {
        logoImageView.contentMode = .scaleAspectFit
        
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = UIColor.checkoutDark()
        
        self.accessoryView = UIImageView(image: UIImage.bundleImage("cell_disclosure_indicator"))
    }
}

// MARK: Configuration

extension PaymentMethodTableViewCell {
    
    func configure(with method: PaymentMethod) {
        self.name = method.name
        self.logoURL = method.logoURL
        
        if let linnearFlow = method.plugin?.linnearFlow(), linnearFlow == false {
            self.accessoryView = nil
        }
    }
}
