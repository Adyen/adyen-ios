//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

internal final class FormCardInstallmentsItem: FormValueItem<Installments, FormTextItemStyle>, Observer, Hidable {
    
    public var isHidden: Observable<Bool> = Observable(false)
    
    /// Options to prepare the picker form items.
    private let installmentOptions: InstallmentOptions
    
    /// To determine the texts of the pickers to include price amount or not.
    private let showAmountInInstallments: Bool
    
    /// Payment amount to be able to divide for installment option texts.
    private let amount: Amount?
    
    private let localizationParameters: LocalizationParameters?
    
    /// Returns installment plan names including one time payment text.
    /// One Time Payment, Installments, Revolving
    private var planChoicesValues: [PaymentPlanPickerElement] {
        guard installmentOptions.includesRevolving else { return [] }
        let oneTimePayment = PaymentPlan(planChoice: .oneTime, localizationParameters: localizationParameters)
        let installments = PaymentPlan(planChoice: .regular, localizationParameters: localizationParameters)
        let revolving = PaymentPlan(planChoice: .revolving, localizationParameters: localizationParameters)
        return [planPickerElement(from: oneTimePayment),
                planPickerElement(from: installments),
                planPickerElement(from: revolving)]
    }
    
    /// Returns installment month choices text, with monthly price added or not.
    /// One note here is that if revolving option is not available, this array contains additional element `1 month`
    /// as the one time payment option
    private var installmentMonthValues: [MonthPickerElement] {
        var months = installmentOptions.regularInstallmentMonths
        if !installmentOptions.includesRevolving {
            months.insert(1, at: 0)
        }
        return months.map(monthPickerElement)
    }
    
    /// Picker to select payment plan when there is revolving option to choose
    internal lazy var planPickerItem: BaseFormPickerItem<PaymentPlan>? = {
        guard !planChoicesValues.isEmpty,
              let firstChoice = planChoicesValues.first else { return nil }
        let item = BaseFormPickerItem<PaymentPlan>(preselectedValue: firstChoice, selectableValues: planChoicesValues, style: style)
        item.title = localizedString(.cardInstallmentsPlan, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "installmentPlan")
        return item
    }()

    /// Picker to contain installment month options.
    internal lazy var monthPickerItem: BaseFormPickerItem<InstallmentMonth>? = {
        guard let first = installmentMonthValues.first else { return nil }
        let item = BaseFormPickerItem<InstallmentMonth>(preselectedValue: first, selectableValues: installmentMonthValues, style: style)
        item.title = localizedString(.cardInstallmentsTitle, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "installmentMonths")
        return item
    }()
    
    internal init(installmentOptions: InstallmentOptions,
                  style: FormTextItemStyle,
                  showAmountInIntallments: Bool,
                  amount: Amount?,
                  localizationParameters: LocalizationParameters? = nil) {
        
        self.installmentOptions = installmentOptions
        self.showAmountInInstallments = showAmountInIntallments
        self.amount = amount
        self.localizationParameters = localizationParameters
        super.init(value: Installments(), style: style)
    }
    
    private func planPickerElement(from paymentPlan: PaymentPlan) -> PaymentPlanPickerElement {
        PaymentPlanPickerElement(identifier: paymentPlan.planChoice.rawValue, element: paymentPlan)
    }
    
    private func monthPickerElement(from monthValue: UInt) -> MonthPickerElement {
        let installmentMonth = InstallmentMonth(month: Int(monthValue),
                                                amount: amount,
                                                showAmount: showAmountInInstallments,
                                                localizationParameters: localizationParameters)
        return MonthPickerElement(identifier: String(installmentMonth.month), element: installmentMonth)
    }
    
    private func preparePickerItems() {
        // if revolving is an option, there will 2 picker items.
        // planPicker and then monthPicker
        // if not, only monthpicker
        // in 2 picker case
        // monthpicker will only be shown if regular plan is selected
        if let planPickerItem = planPickerItem {
            observe(planPickerItem.publisher) { [weak self] change in
                guard let self = self else { return }
                self.value.plan = change.element.installmentPlan
                self.monthPickerItem?.isHidden.wrappedValue = change.element.planChoice != .regular
            }
        }
        if let monthPickerItem = monthPickerItem {
            bind(monthPickerItem.publisher, at: \.element.month, to: self, at: \.value.totalMonths)
        }
        
    }
    
    /// :nodoc:
    override internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

extension FormItemViewBuilder {
    internal func build(with item: FormCardInstallmentsItem) -> FormItemView<FormCardInstallmentsItem> {
        FormVerticalStackItemView(item: item)
    }
}

extension FormCardInstallmentsItem {
    internal typealias PaymentPlanPickerElement = BasePickerElement<PaymentPlan>
    internal typealias MonthPickerElement = BasePickerElement<InstallmentMonth>
    
    /// Custom type to represent plan picker for installment options.
    /// Provides a conversion mechanism to the Installments model.
    internal struct PaymentPlan: CustomStringConvertible {
        internal enum PlanChoice: String {
            case oneTime
            case regular
            case revolving
        }
        
        internal let planChoice: PlanChoice
        internal let localizationParameters: LocalizationParameters?
        
        internal var description: String {
            switch planChoice {
            case .oneTime:
                return localizedString(.cardInstallmentsOneTime, localizationParameters)
            case .regular:
                return localizedString(.cardInstallmentsTitle, localizationParameters)
            case .revolving:
                return localizedString(.cardInstallmentsRevolving, localizationParameters)
            }
        }
        
        /// Converts the picker representable plan to `Installments.Plan` model.
        internal var installmentPlan: Installments.Plan {
            switch planChoice {
            case .oneTime, .regular:
                return .regular
            case .revolving:
                return .revolving
            }
        }
    }
    
    /// Custom type to represent installment month values in a picker.
    internal struct InstallmentMonth: CustomStringConvertible {
        internal let month: Int
        internal let amount: Amount?
        internal let showAmount: Bool
        internal let localizationParameters: LocalizationParameters?
        
        internal var description: String {
            if showAmount, let amount = amount {
                let monthlyAmount = amount.value / month
                return localizedString(.cardInstallmentsMonthsAndPrice, localizationParameters, month, monthlyAmount)
            }
            return localizedString(.cardInstallmentsMonths, localizationParameters, month)
        }
    }
}
