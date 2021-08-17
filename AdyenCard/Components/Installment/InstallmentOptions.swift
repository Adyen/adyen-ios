//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Details to configure Installment Options.
/// These always include regular monthly installments,
/// but in some countries `revolving` option may be added.
public struct InstallmentOptions {
    
    /// Enum to define installment plans.
    internal enum Plan: Hashable {
        
        /// Regular installments with `allowedMonths` as month options.
        case regular(allowedMonths: [UInt])
        
        /// Revolving installment, where the amount to pay monthly is set by the user via their bank.
        case revolving
    }
    
    /// Allowed plans.
    internal let plans: Set<Plan>
    
    /// Creates a new instance of installment options.
    /// - Parameters:
    ///   - monthValues: Allowed installment month values, such as `[1, 2, 3]` or `[1, 3, 6, 9]` etc.
    ///   Must not be empty.
    ///   - includesRevolving: Determines if revolving installment is an option.
    public init(monthValues: [UInt], includesRevolving: Bool) {
        assert(!monthValues.isEmpty, "Month values must not be empty.")
        var plans: Set<Plan> = [.regular(allowedMonths: monthValues)]
        if includesRevolving {
            plans.insert(.revolving)
        }
        self.plans = plans
    }
    
    /// Convenience  initializer to specify the maximum allowed installment month directly,
    /// creating a serial installment options of 1 to `maxInstallmentMonth`.
    /// - Parameters:
    ///   - maxInstallmentMonth: Maximum allowed installment month.
    ///   Resulting `monthValues` array will be `[1, 2 , 3...maxInstallmentMonth]`. Must be greater than 0.
    ///   - includesRevolving: Determines if revolving installment is an option.
    public init(maxInstallmentMonth: UInt, includesRevolving: Bool) {
        assert(maxInstallmentMonth > 0, "Must provide a valid max amount greater than 0.")
        self.init(monthValues: Array(1...maxInstallmentMonth), includesRevolving: includesRevolving)
    }
}

/// Configuration type to specify installment options.
public struct InstallmentConfiguration {
    
    /// The option that apply to all card types, unless included `cardTypeBased` options.
    internal let defaultOptions: InstallmentOptions?
    
    /// Options that are specific to given card types
    internal let cardBasedOptions: [CardType: InstallmentOptions]?
    
    /// Determines whether to show the money amount in the installment selection.
    /// For example, `3 months X 500 USD` or `3 months`.
    internal let showInstallmentPrice: Bool
    
    /// Creates a new installment configuration by providing both the card type based options
    ///  and default options for the rest of the card types.
    /// - Parameters:
    ///   - cardBasedOptions: Options based on the card type. Must not be empty.
    ///   - defaultOptions: Default options for cards that are not specified in `cardBasedOptions`.
    ///   - showInstallmentPrice: Boolean to determine whether to show the money amount next to the installments.
    /// For example, `"3 months X 500 USD"` vs `"3 months"`. Default is `true`.
    public init(cardBasedOptions: [CardType: InstallmentOptions], defaultOptions: InstallmentOptions, showInstallmentPrice: Bool = true) {
        assert(!cardBasedOptions.isEmpty, "This dictionary must not be empty.")
        self.cardBasedOptions = cardBasedOptions
        self.defaultOptions = defaultOptions
        self.showInstallmentPrice = showInstallmentPrice
    }
    
    /// Creates a new installment configuration by providing the card based options.
    /// - Parameters:
    ///   - cardBasedOptions:  Options based on the card type. Must not be empty.
    ///   - showInstallmentPrice: Boolean to determine whether to show the money amount next to the installments.
    /// For example, `"3 months X 500 USD"` vs `"3 months"`. Default is `true`.
    public init(cardBasedOptions: [CardType: InstallmentOptions], showInstallmentPrice: Bool = true) {
        assert(!cardBasedOptions.isEmpty, "This dictionary must not be empty.")
        self.defaultOptions = nil
        self.cardBasedOptions = cardBasedOptions
        self.showInstallmentPrice = showInstallmentPrice
    }
    
    /// Creates a new installment configuration by providing the default options.
    /// - Parameters:
    ///   - defaultOptions: Default options to apply to all card types.
    ///   - showInstallmentPrice: Boolean to determine whether to show the money amount next to the installments.
    /// For example, `"3 months X 500 USD"` vs `"3 months"`. Default is `true`.
    public init(defaultOptions: InstallmentOptions, showInstallmentPrice: Bool = true) {
        self.defaultOptions = defaultOptions
        self.cardBasedOptions = nil
        self.showInstallmentPrice = showInstallmentPrice
    }
    
}
