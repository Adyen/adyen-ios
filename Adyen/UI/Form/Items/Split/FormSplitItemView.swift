//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing a split item.
internal final class FormSplitItemView: FormItemView<FormSplitItem> {

    private let views: [AnyFormItemView]
    
    /// Initializes the split item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormSplitItem) {
        views = item.subitems.map(FormSplitItemView.build)
        super.init(item: item)
        
        addSubview(stackView)
        stackView.adyen.anchor(inside: self)
    }
    
    override internal var childItemViews: [AnyFormItemView] {
        views
    }

    override internal func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        stackView.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
        stackView.alignment = stackView.axis == .vertical ? .fill : .top
        stackView.distribution = stackView.axis == .vertical ? .fill : .fillEqually
        invalidateIntrinsicContentSize()
        adyen.updatePreferredContentSize()
    }
    
    // MARK: - Layout
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: childItemViews)
        stackView.preservesSuperviewLayoutMargins = true
        stackView.axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .vertical : .horizontal
        stackView.alignment = stackView.axis == .vertical ? .fill : .top
        stackView.distribution = stackView.axis == .vertical ? .fill : .fillEqually
        stackView.spacing = 0
        return stackView
    }()

    private static func build(_ item: FormItem) -> AnyFormItemView {
        let itemView = FormItemViewBuilder.build(item)
        itemView.preservesSuperviewLayoutMargins = true
        return itemView
    }
    
}
