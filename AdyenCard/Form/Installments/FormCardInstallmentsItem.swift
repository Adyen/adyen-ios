//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.InstallmentOptions
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormPickerItem
#endif

/// A form element that handles the display and selection of installment options based on the configuration.
internal final class FormCardInstallmentsItem: FormPickerItem<InstallmentElement>, AdyenObserver {

    /// Configurations  to prepare the picker form items.
    private let installmentConfiguration: InstallmentConfiguration

    /// Payment amount to be able to divide for installment option texts.
    private let amount: Amount?

    /// Current card type for which to determine the installments.
    internal private(set) var cardBrand: CardBrand? {
        didSet {
            guard cardBrand != oldValue else { return }
            updatePickerContent()
        }
    }

    private var currentInstallmentOptions: InstallmentOptions? {
        guard let cardBrand else { return installmentConfiguration.defaultOptions }

        return installmentConfiguration.cardBasedOptions?[cardBrand] ?? installmentConfiguration.defaultOptions
    }

    /// Default picker option.
    private lazy var oneTimePaymentElement: InstallmentElement = {
        InstallmentElement(kind: .plan(.oneTime), localizationParameters: localizationParameters)
    }()

    /// The element to select when the available options change.
    /// Preselects the installment count specified by `preselectedValue` if it is an available option,
    /// and falls back to the one-time payment option otherwise.
    private var preselectedElement: InstallmentElement {
        guard let preselectedValue = currentInstallmentOptions?.preselectedValue else { return oneTimePaymentElement }
        return additionalPickerElements.first { $0.identifier == String(preselectedValue) } ?? oneTimePaymentElement
    }

    /// Creates the picker values to display in addition to `oneTimePaymentElement`
    private var additionalPickerElements: [InstallmentElement] {
        guard let currentInstallmentOptions else { return [] }
        var values: [InstallmentElement] = []
        if currentInstallmentOptions.plans.contains(.revolving) {
            values.append(InstallmentElement(kind: .plan(.revolving), localizationParameters: localizationParameters))
        }

        let showAmount = installmentConfiguration.showInstallmentAmount
        let monthValues = currentInstallmentOptions.values.map {
            InstallmentElement(
                kind: .month(InstallmentElement.InstallmentMonth(
                    monthValue: $0,
                    amount: amount,
                    showAmount: showAmount
                )),
                localizationParameters: localizationParameters
            )
        }
        values.append(contentsOf: monthValues)
        return values
    }

    /// Initializes the installments element.
    /// There will be one element in the picker at initialization.
    internal init(
        installmentConfiguration: InstallmentConfiguration,
        style: FormTextItemStyle,
        amount: Amount?,
        presenter: ViewControllerPresenter,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.installmentConfiguration = installmentConfiguration
        self.amount = amount
        let oneTimePaymentElement = InstallmentElement(kind: .plan(.oneTime), localizationParameters: localizationParameters)
        super.init(
            preselectedValue: oneTimePaymentElement,
            selectableValues: [oneTimePaymentElement],
            placeholder: localizedString(.cardInstallmentsOneTimeDescription, localizationParameters),
            style: style,
            presenter: presenter,
            configuration: .init(
                title: localizedString(.cardInstallmentsPickerTitle, localizationParameters),
                subtitle: localizedString(.cardInstallmentsPickerDescription, localizationParameters),
                isSearchEnabled: false
            ),
            localizationParameters: localizationParameters
        )
        updateOptionalStatus(isOptional: true)
        isHidden.wrappedValue = true
        updatePickerContent()
    }

    /// Updates the card type to the given type and triggers a reload on the element.
    internal func update(cardBrand: CardBrand?) {
        self.cardBrand = cardBrand
    }

    private func updatePickerContent() {
        // Reset the selection whenever the available options change (e.g. a card brand switch),
        // so a previously picked option is never shown when it is no longer selectable.
        value = preselectedElement
        // if there is no installment for the current card type then hide and clear the picker
        guard !additionalPickerElements.isEmpty else {
            selectableValues = [oneTimePaymentElement]
            isHidden.wrappedValue = true
            return
        }
        isHidden.wrappedValue = false

        selectableValues = [oneTimePaymentElement] + additionalPickerElements
    }

    override internal func resetValue() {
        value = preselectedElement
    }

    override internal func updateValidationFailureMessage() {
        // Optional field, nothing to update
    }

    override internal func updateFormattedValue() {
        formattedValue = value?.title
        placeholder = value?.subtitle
    }
}
