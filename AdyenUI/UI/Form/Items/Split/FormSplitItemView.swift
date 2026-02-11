//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

/// A view representing a split item.
internal final class FormSplitItemView: FormItemView<FormSplitItem> {

    package let theme: AdyenTheme
    private let views: [AnyFormItemView]
    
    /// Initializes the split item view.
    ///
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - theme: The theme to use for styling.
    init(item: FormSplitItem, theme: AdyenTheme) {
        self.theme = theme
        views = item.subitems.map { FormSplitItemView.build($0, theme: theme) }
        super.init(item: item)
        
        addSubview(stackView)
        stackView.adyen.anchor(inside: self)
    }
    
    required convenience init(item: FormSplitItem) {
        self.init(item: item, theme: .default)
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
        stackView.spacing = 0
        return stackView
    }()

    private static func build(_ item: FormItem, theme: AdyenTheme) -> AnyFormItemView {
        let itemView = item.build(with: FormItemViewBuilder(theme: theme))
        itemView.preservesSuperviewLayoutMargins = true
        return itemView
    }
    
}
