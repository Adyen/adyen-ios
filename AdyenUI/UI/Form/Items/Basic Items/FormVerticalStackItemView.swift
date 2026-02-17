//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A view representing a vertical stack of items.
/// Items are created from the `subitems` property of the `item`
@_spi(AdyenInternal)
open class FormVerticalStackItemView<FormItemType: FormItem>: FormItemView<FormItemType> {

    public private(set) var views: [AnyFormItemView] = []

    private var observations: [Observation] = []

    /// The theme for styling subitems.
    private let theme: AdyenTheme

    /// Initializes the vertical stack item view with theme.
    ///
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - theme: The theme to use for styling subitems.
    public init(item: FormItemType, theme: AdyenTheme) {
        self.theme = theme
        super.init(item: item)

        prepareSubItems()

        if var compound = item as? CompoundFormItem {
            compound.delegate = self
        }

        addSubview(stackView)
        stackView.adyen.anchor(inside: self)
    }

    /// Backward-compatible initializer using default theme.
    public required convenience init(item: FormItemType) {
        self.init(item: item, theme: .default)
    }

    /// Creates a `FormVerticalStackItemView` with the specified spacing between its vertical items.
    /// - Parameters:
    ///   - item: The item represented by the view.
    ///   - itemSpacing: Spacing among the child views of the stack.
    ///   - theme: The theme to use for styling subitems. Defaults to `.default`.
    ///   :nodoc:
    public convenience init(item: FormItemType, itemSpacing: CGFloat, theme: AdyenTheme = .default) {
        self.init(item: item, theme: theme)
        stackView.spacing = itemSpacing
    }

    override public var childItemViews: [AnyFormItemView] {
        views
    }

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

    private func build(_ item: FormItem) -> AnyFormItemView {
        let builder = FormItemViewBuilder(theme: theme)
        let itemView = item.build(with: builder)
        itemView.accessibilityIdentifier = item.identifier
        itemView.preservesSuperviewLayoutMargins = true
        return itemView
    }

    private func prepareSubItems() {
        views.removeAll()
        item.subitems.forEach(prepareSubViews(from:))
    }

    private func prepareSubViews(from subItem: FormItem) {
        let view = build(subItem)
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
        let observation = observe(subItem.isHidden) { isHidden in
            view.adyen.hide(
                animationKey: String(describing: view), hidden: isHidden, animated: true
            )
        }
        observations.append(observation)
    }

    private func removeObservers() {
        observations.forEach(remove)
        observations = []
    }

    override open var canBecomeFirstResponder: Bool {
        views.first { $0.canBecomeFirstResponder } != nil
    }

    override open func becomeFirstResponder() -> Bool {
        views.first { $0.canBecomeFirstResponder }?.becomeFirstResponder()
            ?? super.becomeFirstResponder()
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
