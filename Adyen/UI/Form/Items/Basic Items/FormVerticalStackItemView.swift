//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing a vertical stack of items.
/// Items are created from the `subitems` property of the `item`
/// :nodoc:
open class FormVerticalStackItemView<FormItemType: FormItem>: FormItemView<FormItemType> {

    public private(set) var views: [AnyFormItemView] = []

    private var observations: [Observation] = []

    /// Initializes the split item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: FormItemType) {
        super.init(item: item)

        prepareSubItems()

        if var compound = item as? CompoundFormItem {
            compound.delegate = self
        }

        addSubview(stackView)
        stackView.adyen.anchor(inside: self)
    }

    /// Creates a `FormVerticalStackItemView` with the specified spacing between its vertical items.
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - itemSpacing: Spacing among the child views of the stack.
    ///   :nodoc:
    public convenience init(item: FormItemType, itemSpacing: CGFloat) {
        self.init(item: item)
        stackView.spacing = itemSpacing
    }

    /// :nodoc:
    override public var childItemViews: [AnyFormItemView] { views }

    // MARK: - Layout

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
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
        views.removeAll()
        item.subitems.forEach(prepareSubViews(from:))
    }
    
    private func prepareSubViews(from subItem: FormItem) {
        let view = FormVerticalStackItemView.build(subItem)
        views.append(view)
        let itemView = view as UIView
        stackView.addArrangedSubview(view)
        addVisibilityObserver(for: subItem, view: itemView)

        // weirdest behavior on UIStackView with 2 visible arranged subviews
        // hiding/showing the bottom one glitches the animation
        // workaround is to add another 1px height subview
        if views.count == 2 {
            let extraView = UIView()
            extraView.backgroundColor = .clear
            stackView.addArrangedSubview(extraView)
            extraView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
    }
    
    private func addVisibilityObserver(for subItem: FormItem, view: UIView) {
        guard let subItem = subItem as? Hidable else { return }
        let observation = observe(subItem.isHidden) { isHidden in
            view.adyen.hide(animationKey: String(describing: view), hidden: isHidden, animated: true)
        }
        observations.append(observation)
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
        stackView.setNeedsLayout()
    }

}
