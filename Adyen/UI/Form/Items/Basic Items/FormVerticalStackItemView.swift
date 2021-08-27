//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing a vertical stack of items.
internal final class FormVerticalStackItemView<FormItemType: FormItem>: FormItemView<FormItemType> {

    private var views: [AnyFormItemView] = []

    /// Initializes the split item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormItemType) {
        super.init(item: item)

        views = item.subitems.map(FormVerticalStackItemView.build)

        if var compound = item as? CompoundFormItem {
            compound.delegate = self
        }

        addSubview(stackView)
        stackView.adyen.anchor(inside: self)
    }

    override internal var childItemViews: [AnyFormItemView] { views }

    // MARK: - Layout

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: childItemViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()

    private static func build(_ item: FormItem) -> AnyFormItemView {
        let itemView = FormItemViewBuilder.build(item)
        itemView.preservesSuperviewLayoutMargins = true
        return itemView
    }

}

extension FormVerticalStackItemView: SelfRenderingFormItemDelegate {

    internal func didUpdateItems(_ items: [FormItem]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        views = items.map(FormVerticalStackItemView.build)
        views.forEach(stackView.addArrangedSubview)
        stackView.setNeedsLayout()
        views.first { $0.canBecomeFirstResponder }?.becomeFirstResponder()
    }

}
