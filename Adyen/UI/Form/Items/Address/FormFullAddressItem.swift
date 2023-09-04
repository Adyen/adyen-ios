//
// Copyright (c) 2022 Adyen N.V.
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
    
    internal let supportedCountryCodes: [String]?

    /// :nodoc:
    public private(set) var addressViewModel: AddressViewModel
    
    /// :nodoc:
    private var context: AddressViewModelBuilderContext {
        didSet {
            reloadFields()
        }
    }
    
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
    ///   - supportedCountryCodes: Supported country codes. If `nil`, all country codes are listed.
    public init(initialCountry: String,
                style: AddressStyle,
                localizationParameters: LocalizationParameters? = nil,
                identifier: String? = nil,
                supportedCountryCodes: [String]? = nil) {
        self.initialCountry = initialCountry
        self.localizationParameters = localizationParameters
        self.supportedCountryCodes = supportedCountryCodes
        self.context = .init(countryCode: initialCountry, isOptional: false)
        addressViewModel = AddressViewModel[context]
        super.init(value: PostalAddress(), style: style)

        self.identifier = identifier
        reloadFields()
        
        bind(countrySelectItem.publisher, at: \.identifier, to: self, at: \.value.country)
        observe(countrySelectItem.publisher, eventHandler: { [weak self] event in
            self?.context.countryCode = event.element.identifier
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
        let countries = RegionRepository.regions(from: locale as NSLocale,
                                                 countryCodes: supportedCountryCodes).sorted { $0.name < $1.name }
        let defaultCountry = countries.first { $0.identifier == initialCountry } ?? countries[0]
        let item = FormRegionPickerItem(preselectedValue: defaultCountry,
                                        selectableValues: countries,
                                        style: style.textField)
        item.title = localizedString(.countryFieldTitle, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "country")
        return item
    }()
    
    /// :nodoc:
    public func updateOptionalStatus(isOptional: Bool) {
        context.isOptional = isOptional
    }
    
    // MARK: - Private
    
    private func reloadFields() {
        let subRegions = RegionRepository.subRegions(for: context.countryCode)
        addressViewModel = AddressViewModel[context]
        
        items = [FormSpacerItem(),
                 headerItem.addingDefaultMargins(),
                 countrySelectItem]
        for field in addressViewModel.schema {
            switch field {
            case let .item(fieldType):
                let item = create(for: fieldType, from: addressViewModel, subRegions: subRegions)
                items.append(item)
            case let .split(lhs, rhs):
                let item = FormSplitItem(items: create(for: lhs, from: addressViewModel, subRegions: subRegions),
                                         create(for: rhs, from: addressViewModel, subRegions: subRegions),
                                         style: style)
                items.append(item)
            }
        }
        
        delegate?.didUpdateItems(items)
    }
    
    private func create(for field: AddressField, from viewModel: AddressViewModel, subRegions: [Region]?) -> FormItem {
        let item: FormItem
        if let subRegions, field == .stateOrProvince {
            item = createPickerItem(from: viewModel, subRegions: subRegions)
        } else {
            item = createTextItem(for: field, from: viewModel)
        }
        
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: field.rawValue)
        return item
    }
    
    private func createPickerItem(from viewModel: AddressViewModel, subRegions: [Region]) -> FormItem {
        let defaultRegion = subRegions.first { $0.identifier == value.stateOrProvince } ?? subRegions[0]
        let item = FormRegionPickerItem(preselectedValue: defaultRegion,
                                        selectableValues: subRegions,
                                        style: style.textField)
        item.title = viewModel.labels[.stateOrProvince].map { localizedString($0, localizationParameters) }
        
        bind(item: item, to: .stateOrProvince, subRegions: subRegions)
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
    
    private func bind(item: FormRegionPickerItem, to field: AddressField, subRegions: [Region]) {
        observers[field].map(remove)
        publisherObservers[field].map(remove)
        observers[field] = bind(item.publisher, at: \.identifier, to: self, at: \.value.stateOrProvince)
        func update(address: PostalAddress) {
            let region = subRegions.first { subRegion in
                subRegion.identifier == address.stateOrProvince
            }
            if let region {
                item.value = RegionPickerItem(identifier: region.identifier, element: region)
            }
        }
        update(address: value)
        publisherObservers[.stateOrProvince] = observe(publisher, eventHandler: update(address:))
    }
    
    private func bind(item: FormTextInputItem, to field: AddressField) {
        observers[field].map(remove)
        publisherObservers[field].map(remove)
        
        let item = item
        switch field {
        case .street:
            item.value = value.street ?? ""
            observers[.street] = bind(item.publisher, to: self, at: \.value.street)
            publisherObservers[.street] = observe(publisher) { item.value = $0.street ?? "" }
        case .houseNumberOrName:
            item.value = value.houseNumberOrName ?? ""
            observers[.houseNumberOrName] = bind(item.publisher, to: self, at: \.value.houseNumberOrName)
            publisherObservers[.houseNumberOrName] = observe(publisher) { item.value = $0.houseNumberOrName ?? "" }
        case .apartment:
            item.value = value.apartment ?? ""
            observers[.apartment] = bind(item.publisher, to: self, at: \.value.apartment)
            publisherObservers[.apartment] = observe(publisher) { item.value = $0.apartment ?? "" }
        case .postalCode:
            item.value = value.postalCode ?? ""
            observers[.postalCode] = bind(item.publisher, to: self, at: \.value.postalCode)
            publisherObservers[.postalCode] = observe(publisher) { item.value = $0.postalCode ?? "" }
        case .city:
            item.value = value.city ?? ""
            observers[.city] = bind(item.publisher, to: self, at: \.value.city)
            publisherObservers[.city] = observe(publisher) { item.value = $0.city ?? "" }
        case .stateOrProvince:
            item.value = value.stateOrProvince ?? ""
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
