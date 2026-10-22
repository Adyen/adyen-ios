//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Defines the installment options available for a specific card brand or as a default.
///
/// All values in `values` must be greater than 1.
public struct InstallmentOptions: Equatable, Codable {

    /// An installment plan type.
    public enum Plan: String {
        /// Regular installment payments.
        case regular

        /// Revolving plan, specific to some countries.
        case revolving
    }

    /// List of available installment counts (e.g. [2, 3, 6]).
    public let values: [Int]

    /// The plan types to offer. Defaults to `[.regular]`.
    public let plans: [Plan]

    /// The installment count pre-selected in the UI.
    public let preselectedValue: Int?

    /// Creates a new instance of installment options.
    /// - Parameters:
    ///   - values: Allowed installment counts, such as `[2, 3]` or `[3, 6, 9]` etc.
    ///   Must not be empty and values must be greater than 1.
    ///   - plans: The plan types to offer. Defaults to `[.regular]`.
    ///   - preselectedValue: The installment count pre-selected in the UI.
    public init(
        values: [Int],
        plans: [Plan] = [.regular],
        preselectedValue: Int? = nil
    ) {
        let values = values.filter { $0 > 1 }
        assert(!values.isEmpty, "Values must not be empty and must be greater than 1")
        self.values = values
        self.plans = plans
        self.preselectedValue = preselectedValue
    }

    /// Convenience initializer that generates values in `[2, 3 ... maxInstallments]`.
    /// - Parameters:
    ///   - maxInstallments: Maximum allowed installment count.
    ///   Resulting `values` array will be `[2 , 3...maxInstallments]`. Must be greater than 1.
    ///   - plans: The plan types to offer. Defaults to `[.regular]`.
    ///   - preselectedValue: The installment count pre-selected in the UI.
    public init(
        maxInstallments: Int,
        plans: [Plan] = [.regular],
        preselectedValue: Int? = nil
    ) {
        assert(maxInstallments > 1, "Must provide a valid max amount greater than 1.")
        let values = maxInstallments > 1 ? Array(2...maxInstallments) : []
        self.init(values: values, plans: plans, preselectedValue: preselectedValue)
    }

    @_spi(AdyenInternal)
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let values = try container.decodeIfPresent([Int].self, forKey: .values) ?? []
        self.values = values.filter { $0 > 1 }
        let planStrings = try container.decode([String].self, forKey: .plans)
        self.plans = planStrings.compactMap { Plan(rawValue: $0) }
        self.preselectedValue = try container.decodeIfPresent(Int.self, forKey: .preselectedValue)
    }

    private enum CodingKeys: String, CodingKey {
        case values
        case plans
        case preselectedValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(plans.map(\.rawValue), forKey: .plans)
        try container.encode(values, forKey: .values)
        try container.encodeIfPresent(preselectedValue, forKey: .preselectedValue)
    }
}

/// Installment configuration for the Card Component. Defines which installment plans are available
/// to the shopper.
///
/// `defaultOptions` applies to all card brands unless overridden by `cardBasedOptions`.
public struct InstallmentConfiguration: Decodable, Equatable {

    /// Options applied to all card brands not present in `cardBasedOptions`.
    package let defaultOptions: InstallmentOptions?

    /// Brand-specific options. Overrides `defaultOptions` for matching brands.
    package let cardBasedOptions: [CardBrand: InstallmentOptions]?

    /// Whether to show the per-installment amount in the installment dropdown.
    /// For example, `3 monthly payments of US$ 500` or `3 monthly payments`.
    /// Amount is calculated by simple division.
    package var showInstallmentAmount: Bool

    /// Creates a new installment configuration by providing both the card type based options
    ///  and default options for the rest of the card types.
    /// - Parameters:
    ///   - defaultOptions: Default options for cards that are not specified in `cardBasedOptions`.
    ///   - cardBasedOptions: Options based on the card brand. Must not be empty.
    ///   - showInstallmentAmount: Determines whether to show the amount next to the installment value.
    public init(
        defaultOptions: InstallmentOptions,
        cardBasedOptions: [CardBrand: InstallmentOptions]? = nil,
        showInstallmentAmount: Bool = false
    ) {
        assert(cardBasedOptions?.isEmpty != true, "This dictionary must not be empty.")
        self.defaultOptions = defaultOptions
        self.cardBasedOptions = cardBasedOptions
        self.showInstallmentAmount = showInstallmentAmount
    }

    /// Creates a new installment configuration by providing the card based options.
    /// - Parameters:
    ///   - cardBasedOptions: Options based on the card brand. Must not be empty.
    ///   - showInstallmentAmount: Determines whether to show the amount next to the installment value.
    public init(
        cardBasedOptions: [CardBrand: InstallmentOptions],
        showInstallmentAmount: Bool = false
    ) {
        assert(!cardBasedOptions.isEmpty, "This dictionary must not be empty.")
        self.defaultOptions = nil
        self.cardBasedOptions = cardBasedOptions
        self.showInstallmentAmount = showInstallmentAmount
    }

    @_spi(AdyenInternal)
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        var defaultOptions: InstallmentOptions?
        var cardBased = [CardBrand: InstallmentOptions]()
        
        for key in container.allKeys {
            switch key.stringValue {
            case Constants.regularCards:
                defaultOptions = try container.decodeIfPresent(InstallmentOptions.self, forKey: key)
            default:
                let cardBrand = CardBrand(rawValue: key.stringValue)
                cardBased[cardBrand] = try container.decodeIfPresent(InstallmentOptions.self, forKey: key)
            }
        }
        self.defaultOptions = defaultOptions
        self.cardBasedOptions = cardBased
        self.showInstallmentAmount = false
    }
    
    private enum Constants {
        static let regularCards = "card"
    }
}

private struct DynamicKey: CodingKey {
    internal var intValue: Int?
    internal var stringValue: String

    internal init?(intValue: Int) {
        nil
    }

    internal init?(stringValue: String) {
        self.stringValue = stringValue
    }
}
