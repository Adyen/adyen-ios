//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A full address form, sutable for all countries.
/// :nodoc:
public final class FormAddressItem: FormValueItem<PostalAddress, AddressStyle>, Observer, CompoundFormItem {

    private var items: [FormItem] = []

    private let localizationParameters: LocalizationParameters?

    private var observers: [AddressField: Observation] = [:]

    private var initialCountry: String

    private lazy var validationMessage = localizedString(.validationAlertTitle, localizationParameters)

    private lazy var optionalMessage = localizedString(.fieldTitleOptional, localizationParameters)

    internal weak var delegate: SelfRenderingFormItemDelegate?

    override public var subitems: [FormItem] { items }

    /// Initializes the split text item.
    ///
    /// - Parameter items: The items displayed side-by-side. Must be two.
    /// - Parameter style: The `FormSplitItemView` UI style.
    public init(initialCountry: String, style: AddressStyle, localizationParameters: LocalizationParameters? = nil) {
        self.initialCountry = initialCountry
        self.localizationParameters = localizationParameters
        super.init(value: PostalAddress(), style: style)

        update(for: initialCountry)

        bind(countrySelectItem.publisher, at: \.identifier, to: self, at: \.value.country)
        observe(countrySelectItem.publisher, eventHandler: { event in
            self.update(for: event.element.identifier)
        })
    }

    internal lazy var headerItem: FormItem = {
        let item = FormLabelItem(text: localizedString(.billingAddressSectionTitle, localizationParameters),
                                 style: style.title)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "title")
        return item.addingDefaultMargins()
    }()

    internal lazy var countrySelectItem: FormRegionPickerItem = {
        let locale = localizationParameters?.locale.map { Locale(identifier: $0) } ?? Locale.current
        let countries = RegionRepository.localCountryFallback(for: locale as NSLocale).sorted { $0.name < $1.name }
        let defaultCountry = countries.first { $0.identifier == initialCountry } ?? countries[0]
        let item = FormRegionPickerItem(preselectedValue: defaultCountry,
                                        selectableValues: countries,
                                        style: style.textField)
        item.title = localizedString(.countryFieldTitle, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "country")
        return item
    }()

    private func update(for countryCode: String) {
        let subRegions = RegionRepository.localRegionFallback(for: countryCode, locale: NSLocale.current as NSLocale)
        let viewModel = AddressViewModel[countryCode]

        items = [FormSpacerItem(), headerItem, countrySelectItem]
        for field in viewModel.schema {
            switch field {
            case let .item(fieldType):
                let item = create(for: fieldType, from: viewModel, subRegions: subRegions)
                items.append(item)
            case let .split(lhs, rhs):
                let item = FormSplitItem(items: create(for: lhs, from: viewModel, subRegions: subRegions),
                                         create(for: rhs, from: viewModel, subRegions: subRegions),
                                         style: style)
                items.append(item)
            }
        }

        delegate?.didUpdateItems(items)
    }

    private func create(for field: AddressField, from viewModel: AddressViewModel, subRegions: [Region]?) -> FormItem {
        let item: FormItem
        if let subRegions = subRegions, field == .stateOrProvince {
            item = createPickerItem(from: viewModel, subRegions: subRegions)
        } else {
            item = createTextItem(for: field, from: viewModel)
        }

        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: field.rawValue)
        return item
    }

    private func createPickerItem(from viewModel: AddressViewModel, subRegions: [Region]) -> FormItem {
        let defaultRegion = subRegions.first { $0.identifier == initialCountry } ?? subRegions[0]
        let item = FormRegionPickerItem(preselectedValue: defaultRegion,
                                        selectableValues: subRegions,
                                        style: style.textField)
        item.title = viewModel.labels[.stateOrProvince].map { localizedString($0, localizationParameters) }

        bind(item: item, to: .stateOrProvince)
        return item
    }

    private func createTextItem(for field: AddressField, from viewModel: AddressViewModel) -> FormItem {
        let item = FormTextInputItem(style: style.textField)
        item.validationFailureMessage = validationMessage
        item.title = viewModel.labels[field].map { localizedString($0, localizationParameters) }
        item.placeholder = viewModel.placeholder[field].map { localizedString($0, localizationParameters) }
        item.contentType = field.contentType

        if viewModel.optionalFields.contains(field) {
            if let title = item.title {
                item.title = title + " \(optionalMessage)"
            }
        } else {
            item.validator = LengthValidator(minimumLength: 2, maximumLength: 70)
        }

        bind(item: item, to: field)
        return item
    }

    private func bind(item: FormRegionPickerItem, to field: AddressField) {
        observers[field].map(remove)
        observers[field] = bind(item.publisher, at: \.identifier, to: self, at: \.value.stateOrProvince)
    }

    private func bind(item: FormTextInputItem, to field: AddressField) {
        observers[field].map(remove)

        switch field {
        case .street:
            observers[.street] = bind(item.publisher, to: self, at: \.value.street)
        case .houseNumberOrName:
            observers[.houseNumberOrName] = bind(item.publisher, to: self, at: \.value.houseNumberOrName)
        case .appartment:
            observers[.appartment] = bind(item.publisher, to: self, at: \.value.apartment)
        case .postalCode:
            observers[.postalCode] = bind(item.publisher, to: self, at: \.value.postalCode)
        case .city:
            observers[.city] = bind(item.publisher, to: self, at: \.value.city)
        case .stateOrProvince:
            observers[.stateOrProvince] = bind(item.publisher, to: self, at: \.value.stateOrProvince)
        }
    }

    /// :nodoc:
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}
