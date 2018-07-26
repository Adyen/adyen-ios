//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class ListItemView: UIView {
    internal init() {
        super.init(frame: .zero)
        
        addSubview(customImageView)
        addSubview(titleLabel)
        
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal
    
    internal var title: String = "" {
        didSet {
            updateTitle()
        }
    }
    
    internal var titleAttributes: [NSAttributedStringKey: Any]? {
        didSet {
            updateTitle()
        }
    }
    
    internal var imageURL: URL? {
        didSet {
            if let imageURL = imageURL {
                customImageView.downloadImage(from: imageURL)
            } else {
                customImageView.image = nil
            }
        }
    }
    
    // MARK: - Private
    
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
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isAccessibilityElement = false
        
        return titleLabel
    }()
    
    private func configureConstraints() {
        let constraints = [
            customImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            customImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            customImageView.widthAnchor.constraint(equalToConstant: 40.0),
            customImageView.heightAnchor.constraint(equalToConstant: 26.0),
            titleLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 20.0),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func updateTitle() {
        if let titleAttributes = titleAttributes {
            let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
            titleLabel.attributedText = attributedTitle
        } else {
            titleLabel.text = title
        }
    }
    
}
