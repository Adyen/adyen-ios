//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal class ComponentsItemCell: UICollectionViewCell {
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        func newBackgroundView(color: UIColor) -> UIView {
            let backgroundView = UIView()
            backgroundView.backgroundColor = color
            backgroundView.layer.cornerRadius = 8.0
            backgroundView.layer.masksToBounds = true
            
            return backgroundView
        }
        
        backgroundView = newBackgroundView(color: #colorLiteral(red: 0.9529411765, green: 0.9647058824, blue: 0.9764705882, alpha: 1))
        selectedBackgroundView = newBackgroundView(color: #colorLiteral(red: 0.8, green: 0.8784313725, blue: 1, alpha: 1))
        contentView.layoutMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        
        contentView.addSubview(stackView)
        
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func prepareForReuse() {
        item = nil
    }
    
    // MARK: - Item
    
    internal var item: ComponentsItem? {
        didSet {
            titleLabel.text = item?.title
        }
    }
    
    // MARK: - Title Label
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17.0, weight: .semibold)
        
        return titleLabel
    }()
    
    // MARK: - Stack View
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.preservesSuperviewLayoutMargins = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
