//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing a separator line item.
internal final class FormSeparatorItemView: FormItemView<FormSeparatorItem> {
    
    /// Initializes the separator line item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormSeparatorItem) {
        super.init(item: item)
        
        addSubview(separator)
        
        configureConstraints()
    }
    
    // MARK: - Separator
    
    private lazy var separator: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = item.color
        view.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "separatorLine")
        }
        return view
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        separator.adyen.anchor(inside: self)
        separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
    }
    
}
