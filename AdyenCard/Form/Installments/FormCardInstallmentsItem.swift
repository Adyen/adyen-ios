//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// A form element that handles the display and selection of installment options based on the configuration.
internal final class FormCardInstallmentsItem: BaseFormPickerItem<InstallmentElement>, Observer {
    
    /// Configurations  to prepare the picker form items.
    private let installmentConfiguration: InstallmentConfiguration
    
    /// Payment amount to be able to divide for installment option texts.
    private let amount: Amount?
    
    private let localizationParameters: LocalizationParameters?
    
    /// Current card type for which to determine the installments.
    internal private(set) var cardType: CardType? {
        didSet {
            updatePickerContent()
        }
    }
    
    private var currentInstallmentOptions: InstallmentOptions? {
        guard let cardType else { return installmentConfiguration.defaultOptions }
        
        return installmentConfiguration.cardBasedOptions?[cardType] ?? installmentConfiguration.defaultOptions
    }
    
    /// Default picker option.
    private lazy var oneTimePaymentElement: InstallmentElement = {
        InstallmentElement(kind: .plan(.oneTime), localizationParameters: localizationParameters)
    }()

    /// Creates the picker values to display in addition to `oneTimePaymentElement`
    private var additionalPickerElements: [InstallmentElement] {
        guard let currentInstallmentOptions else { return [] }
        var values: [InstallmentElement] = []
        if currentInstallmentOptions.includesRevolving {
            values.append(InstallmentElement(kind: .plan(.revolving), localizationParameters: localizationParameters))
        }
        
        let showAmount = installmentConfiguration.showInstallmentPrice
        let monthValues = currentInstallmentOptions.regularInstallmentMonths.map {
            InstallmentElement(
                kind: .month(InstallmentElement.InstallmentMonth(monthValue: Int($0),
                                                                 amount: amount,
                                                                 showAmount: showAmount)),
                localizationParameters: localizationParameters
            )
        }
        values.append(contentsOf: monthValues)
        return values
    }

    /// Initializes the installments element.
    /// There will be one element in the picker at initialization.
    internal init(installmentConfiguration: InstallmentConfiguration,
                  style: FormTextItemStyle,
                  amount: Amount?,
                  localizationParameters: LocalizationParameters? = nil) {
        self.installmentConfiguration = installmentConfiguration
        self.amount = amount
        self.localizationParameters = localizationParameters
        let oneTimePaymentElement = InstallmentElement(kind: .plan(.oneTime), localizationParameters: localizationParameters)
        super.init(preselectedValue: oneTimePaymentElement.pickerElement,
                   selectableValues: [oneTimePaymentElement.pickerElement],
                   style: style)
        isHidden.wrappedValue = true
        title = localizedString(.cardInstallmentsNumberOfInstallments, localizationParameters)
        updatePickerContent()
    }

    /// Updates the card type to the given type and triggers a reload on the element.
    internal func update(cardType: CardType?) {
        self.cardType = cardType
    }

    private func updatePickerContent() {
        // if there is no installment for the current card type
        // clear picker and hide the component
        guard !additionalPickerElements.isEmpty else {
            isHidden.wrappedValue = true
            selectableValues = [oneTimePaymentElement.pickerElement]
            return
        }
        isHidden.wrappedValue = false
        
        let newValues = [oneTimePaymentElement] + additionalPickerElements
        selectableValues = newValues.map(\.pickerElement)
    }
    
    /// :nodoc:
    override internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardInstallmentsItem) -> BaseFormPickerItemView<InstallmentElement> {
        FormCardInstallmentsItemView(item: item)
    }
}
