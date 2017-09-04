//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class PaymentMethodTableViewCell: LoadingTableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        contentView.addSubview(logoView)
        contentView.addSubview(nameLabel)
        
        accessibilityTraits |= UIAccessibilityTraitButton
        
        configureConstraints()
    }
    
    override func stopLoadingAnimation() {
        super.stopLoadingAnimation()
        
        // Reset the disclosure indicator, in case it was visible before the loading animation was shown.
        let showsDisclosureIndicator = self.showsDisclosureIndicator
        self.showsDisclosureIndicator = showsDisclosureIndicator
    }
    
    // MARK: Layout
    
    private func configureConstraints() {
        let marginsGuide = contentView.layoutMarginsGuide
        
        let constraints = [
            logoView.leadingAnchor.constraint(equalTo: marginsGuide.leadingAnchor),
            logoView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 40.0),
            logoView.heightAnchor.constraint(equalToConstant: 26.0),
            nameLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 20.0),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: marginsGuide.trailingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: Logo Image View
    
    var logoURL: URL? {
        didSet {
            guard let url = logoURL else {
                logoView.image = nil
                return
            }
            
            logoView.contentMode = .scaleAspectFit
            logoView.layer.cornerRadius = 4
            logoView.layer.borderWidth = 1 / UIScreen.main.nativeScale
            logoView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
            logoView.clipsToBounds = true
            logoView.downloadImage(from: url)
        }
    }
    
    fileprivate lazy var logoView: UIImageView = {
        let logoView = UIImageView()
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        
        return logoView
    }()
    
    // MARK: Name Label
    
    var name: String? {
        didSet {
            nameLabel.text = name
            
            accessibilityLabel = name
        }
    }
    
    fileprivate lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        nameLabel.textColor = UIColor.checkoutDarkGray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.isAccessibilityElement = false
        
        return nameLabel
    }()
    
    // MARK: Disclosure Indicator
    
    /// Boolean value indicating whether the detail indicator should be shown as an accessory.
    internal var showsDisclosureIndicator: Bool = false {
        didSet {
            if showsDisclosureIndicator {
                accessoryView = UIImageView(image: UIImage.bundleImage("cell_disclosure_indicator"))
            } else {
                accessoryView = nil
            }
        }
    }
    
}

// MARK: PaymentMethod Configuration

extension PaymentMethodTableViewCell {
    
    func configure(with method: PaymentMethod) {
        name = method.displayName
        logoURL = method.logoURL
        showsDisclosureIndicator = shouldShowDisclosureIndicator(for: method)
    }
    
    fileprivate func shouldShowDisclosureIndicator(for method: PaymentMethod) -> Bool {
        switch method.txVariant {
        case .ideal, .card, .sepadirectdebit:
            return true
        default:
            return false
        }
    }
    
}
