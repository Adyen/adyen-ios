//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing a split item.
internal final class FormSplitItemView: FormItemView<FormSplitItem> {
    
    /// Initializes the split item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormSplitItem) {
        super.init(item: item)
        
        addSubview(stackView)
        stackView.adyen.anchore(inside: self)
    }
    
    override internal var childItemViews: [AnyFormItemView] {
        [leftItemView, rightItemView]
    }
    
    // MARK: - Items
    
    private lazy var leftItemView: AnyFormItemView = {
        let leftItemView = item.leftItem.build(with: FormItemViewBuilder())
        leftItemView.accessibilityIdentifier = item.leftItem.identifier
        leftItemView.preservesSuperviewLayoutMargins = true
        
        return leftItemView
    }()
    
    private lazy var rightItemView: AnyFormItemView = {
        let rightItemView = item.rightItem.build(with: FormItemViewBuilder())
        rightItemView.accessibilityIdentifier = item.rightItem.identifier
        rightItemView.preservesSuperviewLayoutMargins = true
        
        return rightItemView
    }()
    
    // MARK: - Layout
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: childItemViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
}
