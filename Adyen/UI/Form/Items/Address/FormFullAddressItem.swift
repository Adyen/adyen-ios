//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A full address form, sutable for all countries.
/// :nodoc:
public final class FullFormAddressItem: FormValueItem<AddressInfo, AddressStyle>, Observer {

    private let localizationParameters: LocalizationParameters?

    private var initialCountry: String

    private lazy var validationMessage = ADYLocalizedString("adyen.validationAlert.title", localizationParameters)

    /// Initializes the split text item.
    ///
    /// - Parameter items: The items displayed side-by-side. Must be two.
    /// - Parameter style: The `FormSplitItemView` UI style.
    public init(initialCountry: String, style: AddressStyle, localizationParameters: LocalizationParameters? = nil) {
        self.initialCountry = initialCountry
        self.localizationParameters = localizationParameters
        super.init(value: AddressInfo(), style: style)

        self.subitems = [
            headerItem,
            countrySelecItem,
            houseNumberTextItem,
            streetTextItem,
            apartmentTextItem,
            cityTextItem,
            provinceTextItem,
            postalCodeTextItem
        ]

        bind(countrySelecItem.publisher, at: \.identifier, to: self, at: \.value.country)
        bind(provinceTextItem.publisher, to: self, at: \.value.stateOrProvince)
        bind(cityTextItem.publisher, to: self, at: \.value.city)
        bind(streetTextItem.publisher, to: self, at: \.value.street)
        bind(houseNumberTextItem.publisher, to: self, at: \.value.houseNumberOrName)
        bind(postalCodeTextItem.publisher, to: self, at: \.value.postalCode)
        bind(apartmentTextItem.publisher, to: self, at: \.value.apartment)
    }

    internal lazy var headerItem: FormItem = {
        let item = FormLabelItem(text: ADYLocalizedString("adyen.billingAddressSection.title", localizationParameters),
                                 style: style.title)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "title")
        return item.withPadding(padding: .init(top: 8, left: 0, bottom: 0, right: 0))
    }()

    internal lazy var countrySelecItem: FormRegionPickerItem = {
        let locale = localizationParameters?.locale.map { Locale(identifier: $0) } ?? Locale.current
        let countries = RegionRepository.localCountryFallback(for: locale as NSLocale)
        let defaultCountry = countries.first { $0.identifier == initialCountry } ?? countries[0]
        let item = FormRegionPickerItem(preselectedValue: defaultCountry,
                                        selectableValues: countries,
                                        style: style.textField)
        item.title = ADYLocalizedString("adyen.countryField.title", localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "country")
        return item
    }()

    internal lazy var streetTextItem: FormTextInputItem = {
        let addressTextItem = FormTextInputItem(style: style.textField)
        addressTextItem.title = ADYLocalizedString("adyen.streetField.title", localizationParameters)
        addressTextItem.placeholder = ADYLocalizedString("adyen.streetField.placeholder", localizationParameters)
        addressTextItem.validator = LengthValidator(minimumLength: 2, maximumLength: 70)
        addressTextItem.validationFailureMessage = validationMessage
        addressTextItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "address")

        return addressTextItem
    }()

    internal lazy var houseNumberTextItem: FormTextInputItem = {
        let houseNumberTextItem = FormTextInputItem(style: style.textField)
        houseNumberTextItem.title = ADYLocalizedString("adyen.houseNumberField.title", localizationParameters)
        houseNumberTextItem.placeholder = ADYLocalizedString("adyen.houseNumberField.placeholder", localizationParameters)
        houseNumberTextItem.validator = LengthValidator(minimumLength: 1, maximumLength: 30)
        houseNumberTextItem.validationFailureMessage = validationMessage
        houseNumberTextItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "houseNumber")

        return houseNumberTextItem
    }()

    internal lazy var apartmentTextItem: FormTextInputItem = {
        let apartmentTextItem = FormTextInputItem(style: style.textField)
        let optionalText = ADYLocalizedString("adyen.field.title.optional", localizationParameters)
        let titleText = ADYLocalizedString("adyen.apartmentSuiteField.title", localizationParameters)
        let placeholderText = ADYLocalizedString("adyen.apartmentSuiteField.placeholder", localizationParameters)
        apartmentTextItem.title = "\(titleText) \(optionalText)"
        apartmentTextItem.validator = LengthValidator(minimumLength: 0, maximumLength: 70)
        apartmentTextItem.placeholder = "\(placeholderText) \(optionalText)"
        apartmentTextItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "apartmentSuite")

        return apartmentTextItem
    }()

    internal lazy var cityTextItem: FormTextInputItem = {
        let cityTextItem = FormTextInputItem(style: style.textField)
        cityTextItem.title = ADYLocalizedString("adyen.cityField.title", localizationParameters)
        cityTextItem.placeholder = ADYLocalizedString("adyen.cityField.placeholder", localizationParameters)
        cityTextItem.validator = LengthValidator(minimumLength: 2, maximumLength: 70)
        cityTextItem.validationFailureMessage = validationMessage
        cityTextItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "city")

        return cityTextItem
    }()

    internal lazy var provinceTextItem: FormTextInputItem = {
        let cityTextItem = FormTextInputItem(style: style.textField)
        cityTextItem.title = ADYLocalizedString("adyen.provinceOrTerritoryField.title", localizationParameters)
        cityTextItem.placeholder = ADYLocalizedString("adyen.provinceOrTerritoryField.placeholder", localizationParameters)
        cityTextItem.validator = LengthValidator(minimumLength: 2, maximumLength: 50)
        cityTextItem.validationFailureMessage = validationMessage
        cityTextItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "provinceOrTerritory")

        return cityTextItem
    }()

    internal lazy var postalCodeTextItem: FormTextInputItem = {
        let cityTextItem = FormTextInputItem(style: style.textField)
        cityTextItem.title = ADYLocalizedString("adyen.postalCodeField.title", localizationParameters)
        cityTextItem.placeholder = ADYLocalizedString("adyen.postalCodeField.placeholder", localizationParameters)
        cityTextItem.validator = LengthValidator(minimumLength: 2, maximumLength: 30)
        cityTextItem.validationFailureMessage = validationMessage
        cityTextItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "postalCode")
        return cityTextItem
    }()

    /// :nodoc:
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}
