//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class CheckoutHeaderView: UITableViewHeaderFooterView {
    fileprivate var titleLabel = UILabel()
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
}

extension CheckoutHeaderView {
    
    func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        applyStyling()
        setupTitleConstraints()
    }
    
    func applyStyling() {
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor.checkoutGray
        
        textLabel?.isHidden = true
    }
    
    func setupTitleConstraints() {
        addConstraint(NSLayoutConstraint(
            item: titleLabel,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: 20
        ))
        addConstraint(NSLayoutConstraint(
            item: titleLabel,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: -9
        ))
        addConstraint(NSLayoutConstraint(
            item: titleLabel,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: -20
        ))
    }
}
