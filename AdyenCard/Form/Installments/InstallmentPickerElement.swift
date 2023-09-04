//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// Type that combines month values and plan selections
/// to be able to show in a picker item.
internal struct InstallmentElement: CustomStringConvertible, Equatable {
    
    internal let kind: Kind
    internal let localizationParameters: LocalizationParameters?
    
    internal var description: String {
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
    internal var installmentValue: Installments? {
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
    internal var pickerElement: InstallmentPickerElement {
        switch kind {
        case let .plan(plan):
            return InstallmentPickerElement(identifier: plan.installmentPlan.rawValue, element: self)
        case let .month(month):
            return InstallmentPickerElement(identifier: String(month.monthValue), element: self)
        }
    }
    
    internal enum Kind {
        case plan(PaymentPlan)
        case month(InstallmentMonth)
    }
    
    /// Custom type to represent plans in the picker
    /// Provides a conversion mechanism to the Installments model.
    internal enum PaymentPlan: String {
        case oneTime
        case revolving
        
        internal func title(with localizationParameters: LocalizationParameters?) -> String {
            switch self {
            case .oneTime:
                return localizedString(.cardInstallmentsOneTime, localizationParameters)
            case .revolving:
                return localizedString(.cardInstallmentsRevolving, localizationParameters)
            }
        }
        
        /// Converts the picker representable plan to `Installments.Plan` model.
        internal var installmentPlan: Installments.Plan {
            switch self {
            case .oneTime:
                return .regular
            case .revolving:
                return .revolving
            }
        }
    }

    /// Custom type to represent installment month values in a picker.
    internal struct InstallmentMonth {
        internal let monthValue: Int
        internal let amount: Amount?
        internal let showAmount: Bool
        
        internal func title(with localizationParameters: LocalizationParameters?) -> String {
            var localizedText: String
            if showAmount,
               let amount,
               let formatted = AmountFormatter.formatted(amount: amount.value / monthValue,
                                                         currencyCode: amount.currencyCode) {
                localizedText = localizedString(.cardInstallmentsMonthsAndPrice, localizationParameters, String(monthValue), formatted)
            } else {
                localizedText = localizedString(.cardInstallmentsMonths, localizationParameters, String(monthValue))
            }
            return localizedText
        }
    }
    
    internal static func == (lhs: InstallmentElement, rhs: InstallmentElement) -> Bool {
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
