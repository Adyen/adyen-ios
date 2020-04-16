//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A view representing a footer item.
internal final class FormButtonItemView: FormItemView<FormButtonItem>, Observer {
    
    /// Initializes the footer item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormButtonItem) {
        super.init(item: item)
        
        addSubview(submitButton)
        
        bind(item.showsActivityIndicator, to: submitButton, at: \.showsActivityIndicator)
        
        preservesSuperviewLayoutMargins = true
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Submit Button
    
    private lazy var submitButton: SubmitButton = {
        
        let submitButton = SubmitButton(style: item.style)
        
        submitButton.title = item.title
        submitButton.addTarget(self, action: #selector(didSelectSubmitButton), for: .touchUpInside)
        submitButton.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "button")
        }
        
        submitButton.preservesSuperviewLayoutMargins = true
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        return submitButton
    }()
    
    @objc private func didSelectSubmitButton() {
        item.buttonSelectionHandler?()
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            submitButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            submitButton.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            submitButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
