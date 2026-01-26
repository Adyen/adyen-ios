//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

// TODO: These configurations may be removed/changed to fit the new configuration structure.

/// The configuration of any component that can contain shopper information.
package protocol AnyPersonalInformationConfiguration {
    
    /// The shopper information to be prefilled.
    var shopperInformation: PrefilledShopperInformation? { get }
}

/// Any component's most basic configuration.
public struct BasicComponentConfiguration {

    /// The UI style of the component.
    public var style: FormComponentStyle

    /// The theming to apply to the component's UI.
    package var theme: AdyenTheme = .init()

    /// A Boolean value that determines whether the payment button is displayed. Defaults to `true`.
    @_spi(AdyenInternal)
    public private(set) var showsSubmitButton: Bool

    /// Indicates the localization parameters, leave it nil to use the default parameters.
    public var localizationParameters: LocalizationParameters?

    /// Initializes a new instance of `BasicComponentConfiguration`
    ///
    /// - Parameters:
    ///   - style: The form style.
    ///   - showsSubmitButton: Boolean value that determines whether the payment button is displayed.
    ///   Defaults to `true`.
    ///   - localizationParameters: The localization parameters.
    public init(
        style: FormComponentStyle = FormComponentStyle(),
        showsSubmitButton: Bool = true,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.style = style
        self.showsSubmitButton = showsSubmitButton
        self.localizationParameters = localizationParameters
    }

}

/// The concrete configuration of any component that can contain shopper information.
public struct PersonalInformationConfiguration: AnyPersonalInformationConfiguration {

    /// The UI style of the component.
    public var style: FormComponentStyle

    /// The theming to apply to the component's UI.
    package var theme: AdyenTheme = .init()

    /// A Boolean value that determines whether the payment button is displayed. Defaults to `true`.
    @_spi(AdyenInternal)
    public let showsSubmitButton: Bool

    public var shopperInformation: PrefilledShopperInformation?
    
    public var localizationParameters: LocalizationParameters?

    /// Initializes a new instance of `PersonalInformationConfiguration`
    ///
    /// - Parameters:
    ///   - style: The form style.
    ///   - showsSubmitButton: Boolean value that determines whether the payment button is displayed.
    ///   Defaults to `true`.
    ///   - shopperInformation: The shopper information to be prefilled.
    ///   - localizationParameters: The localization parameters.
    public init(
        style: FormComponentStyle = FormComponentStyle(),
        showsSubmitButton: Bool = true,
        shopperInformation: PrefilledShopperInformation? = nil,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.style = style
        self.showsSubmitButton = showsSubmitButton
        self.shopperInformation = shopperInformation
        self.localizationParameters = localizationParameters
    }

}
