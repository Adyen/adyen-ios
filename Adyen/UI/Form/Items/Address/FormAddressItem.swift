//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A full address form, suitable for all countries.
@_spi(AdyenInternal)
public final class FormAddressItem: FormValueItem<PostalAddress, AddressStyle>, AdyenObserver, CompoundFormItem, Hidable {
    
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    private var context: AddressViewModelBuilderContext {
        didSet {
            self.reloadFields()
        }
    }
    
    override public var value: PostalAddress {
        didSet {
            updateCountryPicker()
        }
    }
    
    private var items: [FormItem] = [] {
        didSet {
            delegate?.didUpdateItems(items)
        }
    }
    
    internal let configuration: Configuration
    
    private var observers: [AddressField: Observation] = [:]
    
    private var publisherObservers: [AddressField: Observation] = [:]
    
    private var initialCountry: String
    
    private lazy var validationMessage = localizedString(.validationAlertTitle, configuration.localizationParameters)
    
    private lazy var optionalMessage = localizedString(.fieldTitleOptional, configuration.localizationParameters)
    
    internal weak var delegate: SelfRenderingFormItemDelegate?
    
    override public var subitems: [FormItem] { items }
    
    internal let addressViewModelBuilder: AddressViewModelBuilder
    
    private weak var presenter: ViewControllerPresenter?
    
    @_spi(AdyenInternal)
    public private(set) var addressViewModel: AddressViewModel

    override public var title: String? {
        didSet {
            headerItem.text = title ?? ""
        }
    }
    
    /// Initializes the form address item.
    /// - Parameters:
    ///   - initialCountry: The initially set country
    ///   - configuration: The configuration of the FormAddressItem
    ///   - identifier: The item identifier
    ///   - addressViewModelBuilder: The Address view model builder
    public init(initialCountry: String,
                configuration: Configuration,
                identifier: String? = nil,
                presenter: ViewControllerPresenter?,
                addressViewModelBuilder: AddressViewModelBuilder) {
        self.initialCountry = initialCountry
        self.configuration = configuration
        self.presenter = presenter
        self.addressViewModelBuilder = addressViewModelBuilder
        self.context = .init(countryCode: initialCountry, isOptional: false)
        addressViewModel = addressViewModelBuilder.build(context: context)
        super.init(value: PostalAddress(country: initialCountry), style: configuration.style)
        self.identifier = identifier
        reloadFields()
        
        observe(countryPickerItem.publisher, eventHandler: { [weak self] event in
            guard let region = event else { return }
            self?.value.country = region.identifier
            self?.context.countryCode = region.identifier
        })
    }
    
    internal lazy var headerItem: FormLabelItem = {
        let item = FormLabelItem(text: localizedString(.billingAddressSectionTitle, configuration.localizationParameters),
                                 style: style.title)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "title")
        return item
    }()
    
    internal lazy var countryPickerItem: FormRegionPickerItem = {
        let locale = Locale(identifier: self.configuration.localizationParameters?.locale ?? Locale.current.identifier)
        
        let countries = RegionRepository.regions(
            from: locale as NSLocale,
            with: self.configuration.supportedCountryCodes
        )
        .sorted { $0.name < $1.name }
        
        let defaultCountry = countries.first { $0.identifier == initialCountry }
        
        return FormRegionPickerItem(
            preselectedRegion: defaultCountry,
            selectableRegions: countries,
            validationFailureMessage: localizedString(
                .countryFieldInvalid,
                configuration.localizationParameters
            ),
            title: localizedString(.countryFieldTitle, configuration.localizationParameters),
            placeholder: localizedString(.countryFieldPlaceholder, configuration.localizationParameters),
            style: style.textField,
            presenter: presenter,
            identifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "country")
        )
    }()
    
    public func updateOptionalStatus(isOptional: Bool) {
        context.isOptional = isOptional
    }
    
    // MARK: - Private
    
    private func updateCountryPicker() {
        guard let country = value.country, country != countryPickerItem.value?.identifier else {
            return
        }
        
        guard let matchingElement = countryPickerItem.selectableValues.first(where: { $0.identifier == value.country }) else {
            AdyenAssertion.assertionFailure(
                message: "The provided country '\(country)' is not supported per configuration."
            )
            return
        }
        
        countryPickerItem.value = matchingElement
    }
    
    private func reloadFields() {
        let subRegions = RegionRepository.subRegions(for: context.countryCode)
        addressViewModel = addressViewModelBuilder.build(context: context)
        
        let header: FormItem? = configuration.showsHeader ? headerItem.addingDefaultMargins() : nil
        
        var formItems: [FormItem?] = [
            FormSpacerItem(),
            header,
            countryPickerItem
        ]
        
        for field in addressViewModel.scheme {
            switch field {
            case let .item(fieldType):
                let item = create(for: fieldType, from: addressViewModel, subRegions: subRegions)
                formItems.append(item)
            case let .split(lhs, rhs):
                let item = FormSplitItem(items: create(for: lhs, from: addressViewModel, subRegions: subRegions),
                                         create(for: rhs, from: addressViewModel, subRegions: subRegions),
                                         style: style)
                formItems.append(item)
            }
        }
        
        self.items = formItems.compactMap { $0 }
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
        let defaultRegion = subRegions.first { $0.identifier == value.stateOrProvince }
        let itemTitle = viewModel.labels[.stateOrProvince].map { localizedString($0, configuration.localizationParameters) } ?? ""
        let item = FormRegionPickerItem(
            preselectedRegion: defaultRegion,
            selectableRegions: subRegions,
            validationFailureMessage: validationMessage,
            title: itemTitle,
            placeholder: itemTitle,
            style: style.textField,
            presenter: presenter
        )
        
        bind(item: item, to: .stateOrProvince, subRegions: subRegions)
        return item
    }
    
    private func createTextItem(for field: AddressField, from viewModel: AddressViewModel) -> FormItem {
        let item = FormTextInputItem(style: style.textField)
        item.validationFailureMessage = validationMessage
        item.title = viewModel.labels[field].map { localizedString($0, configuration.localizationParameters) }
        item.placeholder = viewModel.placeholder[field].map { localizedString($0, configuration.localizationParameters) }
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
        observers[field] = bind(item.publisher, at: \.?.identifier, to: self, at: \.value.stateOrProvince)
        func update(address: PostalAddress) {
            let region = subRegions.first { $0.identifier == address.stateOrProvince }
            item.updateValue(with: region)
        }

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
    
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Resets the item's value to an empty `PostalAddress`.
    public func reset() {
        value = PostalAddress()
    }
}
