//
// Copyright (c) 2020 Adyen N.V.
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
        layoutMargins.bottom = 24.0
        
        addSubview(stackView)
        
        backgroundColor = item.style.backgroundColor
        
        bind(item.showsActivityIndicator, to: submitButton, at: \.showsActivityIndicator)
        
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Submit Button
    
    private lazy var submitButton: SubmitButton = {
        let submitButton = SubmitButton(style: item.style.button)
        submitButton.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "submitButton")
        }
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
        titleLabel.font = item.style.title.font
        titleLabel.textAlignment = item.style.title.textAlignment
        titleLabel.textColor = item.style.title.color
        titleLabel.backgroundColor = item.style.title.backgroundColor
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }
        
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
        stackView.backgroundColor = item.style.backgroundColor
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
