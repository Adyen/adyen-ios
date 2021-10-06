//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing a vertical stack of items.
/// Items are created from the `subitems` property of the `item`
public final class FormVerticalStackItemView<FormItemType: FormItem>: FormItemView<FormItemType> {

    private var views: [AnyFormItemView] = []
    
    private var observations: [Observation] = []

    /// Initializes the split item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormItemType) {
        super.init(item: item)

        prepareSubItems()
        
        if var compound = item as? CompoundFormItem {
            compound.delegate = self
        }

        addSubview(stackView)
        stackView.adyen.anchor(inside: self)
    }
    
    public convenience init(item: FormItemType, itemSpacing: CGFloat) {
        self.init(item: item)
        stackView.spacing = itemSpacing
    }

    override public var childItemViews: [AnyFormItemView] { views }
    
    override public var canBecomeFirstResponder: Bool {
        views.first { $0.canBecomeFirstResponder } != nil
    }
    
    override public func becomeFirstResponder() -> Bool {
        views.first { $0.canBecomeFirstResponder }?.becomeFirstResponder() ?? super.becomeFirstResponder()
    }

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
    
    private func prepareSubItems() {
        item.subitems.forEach { subItem in
            let view = FormVerticalStackItemView.build(subItem)
            views.append(view)
            let itemView = view as UIView
            if let subItem = subItem as? Hidable {
                let observation = observe(subItem.isHidden) { newValue in
                    itemView.adyen.hide(animationKey: String(describing: itemView), hidden: newValue, animated: true)
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                        itemView.isHidden = newValue
                        itemView.alpha = newValue ? 0 : 1
                    }

                }
                observations.append(observation)
            }
        }
    }
    
    private func removeObservers() {
        observations.forEach(remove)
        observations = []
    }

}

extension FormVerticalStackItemView: SelfRenderingFormItemDelegate {

    internal func didUpdateItems(_ items: [FormItem]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        removeObservers()
        prepareSubItems()
        views.forEach(stackView.addArrangedSubview)
        stackView.setNeedsLayout()
        views.first { $0.canBecomeFirstResponder }?.becomeFirstResponder()
    }

}
