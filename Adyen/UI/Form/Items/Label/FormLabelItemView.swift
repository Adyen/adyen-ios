//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a header item.
internal final class FormLabelItemView: FormItemView<UILabel> {

    /// Initializes the header item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: UILabel) {
        super.init(item: item)
        
        setupLabel()
        configureConstraints()
    }
    
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private

    private func setupLabel() {
        addSubview(item)
        item.adjustsFontForContentSizeCategory = true
        item.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureConstraints() {
        let constraints = [
            item.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 7),
            item.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            item.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            item.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -7)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
