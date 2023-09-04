//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Type that combines month values and plan selections
/// to be able to show in a picker item.
struct InstallmentElement: CustomStringConvertible, Equatable {
    
    let kind: Kind
    let localizationParameters: LocalizationParameters?
    
    var description: String {
        switch kind {
        case let .plan(plan):
            return plan.title(with: localizationParameters)
        case let .month(month):
            return month.title(with: localizationParameters)
        }
    }
    
    /// Creates an appropriate `Installments.Plan` from the picker element instance.
    /// Returns nil if the resulting installment does not fit the requirements.
    /// These rules are: month values > 1 for regular plan
    /// and month value = 1 for revolving plan
    var installmentValue: Installments? {
        switch kind {
        case let .plan(plan):
            if plan.installmentPlan == .revolving {
                return Installments(totalMonths: 1, plan: plan.installmentPlan)
            } else {
                return nil
            }
        case let .month(month):
            return Installments(totalMonths: month.monthValue, plan: .regular)
        }
    }
    
    /// Value to be represented in a BaseFormPickerItem
    var pickerElement: InstallmentPickerElement {
        switch kind {
        case let .plan(plan):
            return InstallmentPickerElement(identifier: plan.installmentPlan.rawValue, element: self)
        case let .month(month):
            return InstallmentPickerElement(identifier: String(month.monthValue), element: self)
        }
    }
    
    enum Kind {
        case plan(PaymentPlan)
        case month(InstallmentMonth)
    }
    
    /// Custom type to represent plans in the picker
    /// Provides a conversion mechanism to the Installments model.
    enum PaymentPlan: String {
        case oneTime
        case revolving
        
        func title(with localizationParameters: LocalizationParameters?) -> String {
            switch self {
            case .oneTime:
                return localizedString(.cardInstallmentsOneTime, localizationParameters)
            case .revolving:
                return localizedString(.cardInstallmentsRevolving, localizationParameters)
            }
        }
        
        /// Converts the picker representable plan to `Installments.Plan` model.
        var installmentPlan: Installments.Plan {
            switch self {
            case .oneTime:
                return .regular
            case .revolving:
                return .revolving
            }
        }
    }

    /// Custom type to represent installment month values in a picker.
    struct InstallmentMonth {
        let monthValue: Int
        let amount: Amount?
        let showAmount: Bool
        
        func title(with localizationParameters: LocalizationParameters?) -> String {
            var localizedText: String
            if showAmount,
               let amount = amount,
               let formatted = AmountFormatter.formatted(amount: amount.value / monthValue,
                                                         currencyCode: amount.currencyCode) {
                localizedText = localizedString(.cardInstallmentsMonthsAndPrice, localizationParameters, String(monthValue), formatted)
            } else {
                localizedText = localizedString(.cardInstallmentsMonths, localizationParameters, String(monthValue))
            }
            return localizedText
        }
    }
    
    static func == (lhs: InstallmentElement, rhs: InstallmentElement) -> Bool {
        switch (lhs.kind, rhs.kind) {
        case let (.plan(lPlan), .plan(rPLan)):
            return lPlan == rPLan
        case let (.month(lMonth), .month(rMonth)):
            return lMonth.monthValue == rMonth.monthValue
        default:
            return false
        }
    }
}
