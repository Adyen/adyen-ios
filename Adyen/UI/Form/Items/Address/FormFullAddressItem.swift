//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A full address form, suitable for all countries.
/// :nodoc:
public final class FormAddressItem: FormValueItem<PostalAddress, AddressStyle>, Observer, CompoundFormItem, Hidable {
    
    /// :nodoc:
    public var isHidden: Observable<Bool> = Observable(false)
    
    private var items: [FormItem] = []
    
    private let localizationParameters: LocalizationParameters?
    
    private var observers: [AddressField: Observation] = [:]
    private var publisherObservers: [AddressField: Observation] = [:]
    
    private var initialCountry: String
    
    private lazy var validationMessage = localizedString(.validationAlertTitle, localizationParameters)
    
    private lazy var optionalMessage = localizedString(.fieldTitleOptional, localizationParameters)
    
    internal weak var delegate: SelfRenderingFormItemDelegate?
    
    override public var subitems: [FormItem] { items }
    
    override public var title: String? {
        didSet {
            headerItem.text = title ?? ""
        }
    }

    /// Initializes the split text item.
    /// - Parameters:
    ///   - initialCountry: The items displayed side-by-side. Must be two.
    ///   - style: The `FormSplitItemView` UI style.
    ///   - localizationParameters: The localization parameters
    ///   - identifier: The item identifier
    public init(initialCountry: String,
                style: AddressStyle,
                localizationParameters: LocalizationParameters? = nil,
                identifier: String? = nil) {
        self.initialCountry = initialCountry
        self.localizationParameters = localizationParameters
        super.init(value: PostalAddress(), style: style)

        self.identifier = identifier
        update(for: initialCountry)
        
        bind(countrySelectItem.publisher, at: \.identifier, to: self, at: \.value.country)
        observe(countrySelectItem.publisher, eventHandler: { [weak self] event in
            self?.update(for: event.element.identifier)
        })
    }
    
    internal lazy var headerItem: FormLabelItem = {
        let item = FormLabelItem(text: localizedString(.billingAddressSectionTitle, localizationParameters),
                                 style: style.title)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "title")
        return item
    }()
    
    internal lazy var countrySelectItem: FormRegionPickerItem = {
        let locale = Locale(identifier: localizationParameters?.locale ?? Locale.current.identifier)
        let countries = RegionRepository.localCountryFallback(for: locale as NSLocale).sorted { $0.name < $1.name }
        let defaultCountry = countries.first { $0.identifier == initialCountry } ?? countries[0]
        let item = FormRegionPickerItem(preselectedValue: defaultCountry,
                                        selectableValues: countries,
                                        style: style.textField)
        item.title = localizedString(.countryFieldTitle, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "country")
        return item
    }()
    
    // MARK: - Private
    
    private func update(for countryCode: String) {
        let subRegions = RegionRepository.localRegionFallback(for: countryCode, locale: NSLocale.current as NSLocale)
        let viewModel = AddressViewModel[countryCode]
        
        items = [FormSpacerItem(),
                 headerItem.addingDefaultMargins(),
                 countrySelectItem]
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
            item.validator = LengthValidator(minimumLength: 1, maximumLength: 70)
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
        publisherObservers[field].map(remove)
        
        let item = item
        switch field {
        case .street:
            observers[.street] = bind(item.publisher, to: self, at: \.value.street)
            publisherObservers[.street] = observe(publisher) { item.value = $0.street ?? "" }
        case .houseNumberOrName:
            observers[.houseNumberOrName] = bind(item.publisher, to: self, at: \.value.houseNumberOrName)
            publisherObservers[.houseNumberOrName] = observe(publisher) { item.value = $0.houseNumberOrName ?? "" }
        case .apartment:
            observers[.apartment] = bind(item.publisher, to: self, at: \.value.apartment)
            publisherObservers[.apartment] = observe(publisher) { item.value = $0.apartment ?? "" }
        case .postalCode:
            observers[.postalCode] = bind(item.publisher, to: self, at: \.value.postalCode)
            publisherObservers[.postalCode] = observe(publisher) { item.value = $0.postalCode ?? "" }
        case .city:
            observers[.city] = bind(item.publisher, to: self, at: \.value.city)
            publisherObservers[.city] = observe(publisher) { item.value = $0.city ?? "" }
        case .stateOrProvince:
            observers[.stateOrProvince] = bind(item.publisher, to: self, at: \.value.stateOrProvince)
            publisherObservers[.stateOrProvince] = observe(publisher) { item.value = $0.stateOrProvince ?? "" }
        case .country:
            break
        }
    }
        
    // MARK: - Public
    
    /// :nodoc:
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Resets the item's value to an empty `PostalAddress`.
    public func reset() {
        value = PostalAddress()
    }
}
