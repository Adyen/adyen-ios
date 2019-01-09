//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

class GiroPayIssuerView: UIView {
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.clear
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(accessoryContainer)
        
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onCloseButtonTap: (() -> Void)? {
        didSet {
            if oldValue == nil {
                accessoryContainer.addSubview(closeButton)
                accessoryWidthConstraint?.constant = closeButton.bounds.width + 20
                
                let constraints = [
                    closeButton.centerYAnchor.constraint(equalTo: accessoryContainer.centerYAnchor),
                    closeButton.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor)
                ]
                
                NSLayoutConstraint.activate(constraints)
            }
        }
    }
    
    var title: String? {
        didSet {
            if let title = title {
                titleLabel.attributedText = NSAttributedString(string: title, attributes: Appearance.shared.textAttributes)
                dynamicTypeController.observeDynamicType(for: titleLabel, withTextAttributes: Appearance.shared.textAttributes, textStyle: .footnote)
            } else {
                titleLabel.text = title
            }
        }
    }
    
    var subtitle: String? {
        didSet {
            if let subtitle = subtitle {
                subtitleLabel.attributedText = NSAttributedString(string: subtitle, attributes: Appearance.shared.listAttributes.cellSubtitleAttributes)
                dynamicTypeController.observeDynamicType(for: subtitleLabel, withTextAttributes: Appearance.shared.listAttributes.cellSubtitleAttributes, textStyle: .footnote)
            } else {
                subtitleLabel.text = subtitle
            }
        }
    }
    
    // MARK: - Private
    
    private var accessoryWidthConstraint: NSLayoutConstraint?
    
    private let dynamicTypeController = DynamicTypeController()
    
    private lazy var accessoryContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        var button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage.bundleImage("cell_close"), for: .normal)
        button.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        
        return button
    }()
    
    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return titleLabel
    }()
    
    private var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.isAccessibilityElement = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return subtitleLabel
    }()
    
    private func configureConstraints() {
        accessoryWidthConstraint = NSLayoutConstraint(item: accessoryContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
            
            accessoryContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            accessoryContainer.heightAnchor.constraint(equalTo: heightAnchor),
            accessoryWidthConstraint!,
            
            bottomAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 9)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func didTapCloseButton() {
        onCloseButtonTap?()
    }
}
