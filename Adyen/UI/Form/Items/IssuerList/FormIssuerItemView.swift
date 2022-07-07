//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class FormIssuerItemView: FormTextItemView<FormIssuerListItem> {

    /// Initializes the issuer list item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormIssuerListItem) {
        super.init(item: item)
        showsSeparator = true
        textField.textContentType = .name
    }

    override internal var childItemViews: [AnyFormItemView] {
        [issuersView]
    }

    // MARK: - Private

    private lazy var issuersView: AnyFormItemView = {
        let view = item.issuerItem.build(with: FormItemViewBuilder())
        view.accessibilityIdentifier = item.issuerItem.identifier
        view.preservesSuperviewLayoutMargins = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}
