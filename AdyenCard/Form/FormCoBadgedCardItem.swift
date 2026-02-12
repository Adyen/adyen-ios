//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// CoBadged card form item.
internal final class FormCoBadgedCardItem: FormItem {

    internal var subitems: [FormItem] = []

    /// The title of the item.
    internal var title: String

    /// The subtitle of the item.
    internal var subtitle: String

    /// The array of selectable form items.
    @AdyenObservable([]) internal var selectableFormItems: [SelectableFormItem]

    /// The `accessibilityIdentifier` to be used on the `FormCoBadgedCardItem`
    internal var identifier: String?

    /// The `accessibilityLabel` to be used on the ``FormCoBadgedCardItem``
    internal let accessibilityLabel: String

    internal var isHidden: AdyenObservable<Bool> = AdyenObservable(true)

    /// The coBadged card item style.
    internal var style: FormCoBadgedCardItemStyle

    /// The callback to send the selected brand to the Card Viewcontroller
    internal var onCardBrandSelection: ((CardBrand) -> Void)?

    /// Brands set after coBadgedCardItems are displayed on the view
    @AdyenObservable(nil) internal var updatedCardBrands: [CardBrand]?

    /// Initializes the FormCoBadged card item.
    ///
    /// - Parameters:
    ///   - title: The title of the coBadged card selection UI.
    ///   - subtitle: The subtitle of the coBadged card selection UI.
    ///   - selectableFormItems: The array of the selectableFormItems.
    ///   - style: The style of the coBadged card form item.
    ///   - identifier: The `accessibilityIdentifier` to be used on the `FormCoBadgedCardItem`
    ///   - accessibilityLabel: An optional custom `accessibilityLabel` to use.
    internal init(
        title: String,
        subtitle: String,
        selectableFormItems: [SelectableFormItem],
        style: FormCoBadgedCardItemStyle,
        identifier: String? = nil,
        accessibilityLabel: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.identifier = identifier
        self.accessibilityLabel = accessibilityLabel ?? ""
        self.selectableFormItems = selectableFormItems
    }

    // MARK: - BuildableFormItem

    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

    internal func selectableFormItems(
        from brands: [CardBrand],
        cardLogos: [FormCardLogosItem.CardTypeLogo],
        defaultSelectedBrand: CardBrand
    ) -> [SelectableFormItem] {
        brands.map { brand in
            let brandLogoURL = cardLogos.first(where: { $0.type == brand.type })?.url

            let isSelected = brand.type.rawValue == defaultSelectedBrand.type.rawValue ? true : false

            // Title should be 'localeBrand' and if it is nil then use 'brand' property from binLookup
            let selectableItem = SelectableFormItem(
                title: brand.localeBrand ?? brand.type.rawValue,
                imageUrl: brandLogoURL,
                isSelected: isSelected,
                style: .init(
                    title: style.title,
                    separatorColor: UIColor.Adyen.componentSeparator
                ),
                identifier: brand.type.rawValue
            )
            selectableItem.selectionHandler = { [weak self] in
                guard let self else { return }
                onCardBrandSelection?(brand)
            }
            return selectableItem
        }
    }

    internal func updateItems(_ brands: [CardBrand], cardLogos: [FormCardLogosItem.CardTypeLogo]) {
        selectableFormItems = []
        updatedCardBrands = []
        if brands.count == 2, brands.allSatisfy(\.isSupported) {
            guard let defaultSelectedBrand = brands.first else {
                return
            }
            selectableFormItems = selectableFormItems(
                from: brands,
                cardLogos: cardLogos,
                defaultSelectedBrand: defaultSelectedBrand
            )
            isHidden.wrappedValue = false
            updatedCardBrands = brands
        } else {
            isHidden.wrappedValue = true
        }
    }

    internal func updateSelection(_ selectedBrand: CardBrand) {
        selectableFormItems.forEach { $0.isSelected = false }
        selectableFormItems.first(where: { $0.identifier == selectedBrand.type.rawValue })?.isSelected = true
    }

    internal func resetItems() {
        selectableFormItems = []
    }
}

extension FormItemViewBuilder {
    internal func build(with item: FormCoBadgedCardItem) -> FormItemView<FormCoBadgedCardItem> {
        FormCoBadgedCardItemView(item: item)
    }
}
