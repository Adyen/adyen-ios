//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// Describes the interface to have an installments configuration.
public protocol InstallmentConfigurationAware: AdyenSessionAware {
    var installmentConfiguration: InstallmentConfiguration? { get }
}

/// Details to configure Installment Options.
/// These always include regular monthly installments,
/// but in some countries `revolving` option may be added.
public struct InstallmentOptions: Equatable, Codable {
    
    @_spi(AdyenInternal)
    /// Month options for regular installments.
    public let regularInstallmentMonths: [UInt]
    
    @_spi(AdyenInternal)
    /// Determines if revolving installment is an option.
    public let includesRevolving: Bool
    
    /// Creates a new instance of installment options.
    /// - Parameters:
    ///   - monthValues: Allowed installment month values, such as `[2, 3]` or `[3, 6, 9]` etc.
    ///   Must not be empty and values must be greater than 1.
    ///   - includesRevolving: Determines if revolving installment is an option.
    public init(monthValues: [UInt], includesRevolving: Bool) {
        let monthValues = monthValues.filter { $0 > 1 }
        assert(!monthValues.isEmpty, "Month values must not be empty and must be greater than 1")
        regularInstallmentMonths = monthValues
        self.includesRevolving = includesRevolving
    }
    
    /// Convenience  initializer to specify the maximum allowed installment month directly,
    /// creating a serial installment options of 2 to `maxInstallmentMonth`.
    /// - Parameters:
    ///   - maxInstallmentMonth: Maximum allowed installment month.
    ///   Resulting `monthValues` array will be `[2 , 3...maxInstallmentMonth]`. Must be greater than 1.
    ///   - includesRevolving: Determines if revolving installment is an option.
    public init(maxInstallmentMonth: UInt, includesRevolving: Bool) {
        assert(maxInstallmentMonth > 1, "Must provide a valid max amount greater than 1.")
        self.init(monthValues: Array(2...maxInstallmentMonth), includesRevolving: includesRevolving)
    }
    
    @_spi(AdyenInternal)
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.regularInstallmentMonths = try container.decodeIfPresent([UInt].self, forKey: .regularInstallmentMonths) ?? []
        let plans = try container.decode([String].self, forKey: .plans)
        self.includesRevolving = plans.contains(Installments.Plan.revolving.rawValue)
    }
    
    private enum CodingKeys: String, CodingKey {
        case plans
        case regularInstallmentMonths = "values"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var plans = [Installments.Plan.regular.rawValue]
        if includesRevolving {
            plans.append(Installments.Plan.revolving.rawValue)
        }
        
        try container.encode(plans, forKey: .plans)
        try container.encode(regularInstallmentMonths, forKey: .regularInstallmentMonths)
    }
}

/// Configuration type to specify installment options.
public struct InstallmentConfiguration: Decodable {
    
    @_spi(AdyenInternal)
    /// The option that apply to all card types, unless included `cardTypeBased` options.
    public let defaultOptions: InstallmentOptions?
    
    @_spi(AdyenInternal)
    /// Options that are specific to given card types
    public let cardBasedOptions: [CardType: InstallmentOptions]?
    
    /// Determines whether to show the money amount in the installment selection.
    /// For example, `3 months X 500 USD` or `3 months`.
    /// For now it is disabled due to making the dividing calculations in the client.
    @_spi(AdyenInternal)
    public let showInstallmentPrice: Bool
    
    /// Creates a new installment configuration by providing both the card type based options
    ///  and default options for the rest of the card types.
    /// - Parameters:
    ///   - cardBasedOptions: Options based on the card type. Must not be empty.
    ///   - defaultOptions: Default options for cards that are not specified in `cardBasedOptions`.
    public init(cardBasedOptions: [CardType: InstallmentOptions], defaultOptions: InstallmentOptions) {
        assert(!cardBasedOptions.isEmpty, "This dictionary must not be empty.")
        self.cardBasedOptions = cardBasedOptions
        self.defaultOptions = defaultOptions
        self.showInstallmentPrice = false
    }
    
    /// Creates a new installment configuration by providing the card based options.
    /// - Parameters:
    ///   - cardBasedOptions:  Options based on the card type. Must not be empty.
    public init(cardBasedOptions: [CardType: InstallmentOptions]) {
        assert(!cardBasedOptions.isEmpty, "This dictionary must not be empty.")
        self.defaultOptions = nil
        self.cardBasedOptions = cardBasedOptions
        self.showInstallmentPrice = false
    }
    
    /// Creates a new installment configuration by providing the default options.
    /// - Parameters:
    ///   - defaultOptions: Default options to apply to all card types.
    public init(defaultOptions: InstallmentOptions) {
        self.defaultOptions = defaultOptions
        self.cardBasedOptions = nil
        self.showInstallmentPrice = false
    }
    
    @_spi(AdyenInternal)
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        var defaultOptions: InstallmentOptions?
        var cardBased = [CardType: InstallmentOptions]()
        
        for key in container.allKeys {
            switch key.stringValue {
            case Constants.regularCards:
                defaultOptions = try container.decodeIfPresent(InstallmentOptions.self, forKey: key)
            default:
                let cardType = CardType(rawValue: key.stringValue)
                cardBased[cardType] = try container.decodeIfPresent(InstallmentOptions.self, forKey: key)
            }
        }
        self.defaultOptions = defaultOptions
        self.cardBasedOptions = cardBased
        self.showInstallmentPrice = false
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
