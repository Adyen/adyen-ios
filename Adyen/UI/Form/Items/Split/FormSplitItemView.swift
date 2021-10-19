//
// Copyright (c) 2021 Adyen N.V.
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
    
    // MARK: - Layout
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: childItemViews)
        stackView.preservesSuperviewLayoutMargins = true
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()

    private static func build(_ item: FormItem) -> AnyFormItemView {
        let itemView = FormItemViewBuilder.build(item)
        itemView.preservesSuperviewLayoutMargins = true
        return itemView
    }
    
}
