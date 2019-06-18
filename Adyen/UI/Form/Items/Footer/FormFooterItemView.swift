//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A view representing a footer item.
internal final class FormFooterItemView: FormItemView<FormFooterItem>, Observer {
    
    /// Initializes the footer item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormFooterItem) {
        super.init(item: item)
        
        layoutMargins.top = 24.0
        
        addSubview(stackView)
        
        bind(item.showsActivityIndicator, to: submitButton, at: \.showsActivityIndicator)
        
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Submit Button
    
    private lazy var submitButton: SubmitButton = {
        let submitButton = SubmitButton()
        submitButton.title = item.submitButtonTitle
        submitButton.addTarget(self, action: #selector(didSelectSubmitButton), for: .touchUpInside)
        
        return submitButton
    }()
    
    @objc private func didSelectSubmitButton() {
        item.submitButtonSelectionHandler?()
    }
    
    // MARK: - Title Label
    
    private lazy var titleLabel: UILabel? = {
        guard let title = item.title else {
            return nil
        }
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13.0)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .lightGray
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        
        return titleLabel
    }()
    
    // MARK: - Stack View
    
    private lazy var stackView: UIStackView = {
        let arrangedSubviews = [submitButton, titleLabel].compactMap { $0 }
        
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12.0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.preservesSuperviewLayoutMargins = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
