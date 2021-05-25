//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing a footer item.
internal final class FormButtonItemView: FormItemView<FormButtonItem> {
    
    /// Initializes the footer item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormButtonItem) {
        super.init(item: item)
        backgroundColor = item.style.backgroundColor
        
        addSubview(submitButton)

        preservesSuperviewLayoutMargins = true
        
        bind(item.$showsActivityIndicator, to: submitButton, at: \.showsActivityIndicator)
        bind(item.$enabled, to: submitButton, at: \.isEnabled)
        bind(item.$title, to: submitButton, at: \.title)
        
        submitButton.adyen.anchor(inside: self.layoutMarginsGuide)
    }
    
    // MARK: - Submit Button
    
    internal lazy var submitButton: SubmitButton = {
        let submitButton = SubmitButton(style: item.style.button)

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
    
}
