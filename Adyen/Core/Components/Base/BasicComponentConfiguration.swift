//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any component's most basic configuration.
public protocol AnyBasicComponentConfiguration: Localizable {

    /// A Boolean value that determines whether the payment button is displayed. Defaults to `false`.
    var hideDefaultPayButton: Bool { get }
}

/// The configuration of any component thats aware of shoppers' personal information.
public protocol AnyPersonalInformationConfiguration: AnyBasicComponentConfiguration {
    
    /// The shopper information to be prefilled.
    var shopperInformation: PrefilledShopperInformation? { get }
}

/// Any component's most basic configuration.
public struct BasicComponentConfiguration: AnyBasicComponentConfiguration {

    /// The UI style of the component.
    public var style: FormComponentStyle

    /// A Boolean value that determines whether the payment button is displayed. Defaults to `false`.
    public var hideDefaultPayButton: Bool

    public var localizationParameters: LocalizationParameters?

    /// Initializes a new instance of `BasicComponentConfiguration`
    ///
    /// - Parameters:
    ///   - style: The form style.
    ///   - hideDefaultPayButton: Boolean value that determines whether the payment button is displayed.
    ///   Defaults to `false`.
    ///   - localizationParameters: The localization parameters.
    public init(style: FormComponentStyle = FormComponentStyle(),
                hideDefaultPayButton: Bool = false,
                localizationParameters: LocalizationParameters? = nil) {
        self.style = style
        self.localizationParameters = localizationParameters
        self.hideDefaultPayButton = hideDefaultPayButton
    }

}

/// The configuration of any component thats aware of shoppers' personal information.
public struct PersonalInformationConfiguration: AnyPersonalInformationConfiguration {

    /// The UI style of the component.
    public var style: FormComponentStyle

    /// A Boolean value that determines whether the payment button is displayed. Defaults to `false`.
    public var hideDefaultPayButton: Bool

    public var shopperInformation: PrefilledShopperInformation?
    
    public var localizationParameters: LocalizationParameters?

    /// Initializes a new instance of `PersonalInformationConfiguration`
    ///
    /// - Parameters:
    ///   - style: The form style.
    ///   - hideDefaultPayButton: Boolean value that determines whether the payment button is displayed.
    ///   Defaults to `false`.
    ///   - shopperInformation: The shopper information to be prefilled.
    ///   - localizationParameters: The localization parameters.
    public init(style: FormComponentStyle = FormComponentStyle(),
                hideDefaultPayButton: Bool = false,
                shopperInformation: PrefilledShopperInformation? = nil,
                localizationParameters: LocalizationParameters? = nil) {
        self.style = style
        self.hideDefaultPayButton = hideDefaultPayButton
        self.shopperInformation = shopperInformation
        self.localizationParameters = localizationParameters
    }

}
