//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any component's most basic configuration.
public protocol AnyBasicComponentConfiguration: Localizable {

    /// The payment information.
    var payment: Payment? { get }
}

/// Any presentable payment component basic configuration.
public protocol AnyPresentableComponentConfiguration: AnyBasicComponentConfiguration {

    associatedtype StyleType

    /// The UI style of the component.
    var style: StyleType { get }

}

/// The configuration of any component thats aware of shoppers' personal information.
public protocol AnyPersonalInformationConfiguration: AnyPresentableComponentConfiguration {
    
    /// The shopper information to be prefilled.
    var shopperInformation: PrefilledShopperInformation? { get }
}

/// Any component's most basic configuration.
public struct BasicComponentConfiguration: AnyPresentableComponentConfiguration {

    public var payment: Payment?

    public var style: FormComponentStyle
    
    public var localizationParameters: LocalizationParameters?
    
    /// Initializes a new instance of `BasicComponentConfiguration`
    ///
    /// - Parameters:
    ///   - style: The form style.
    ///   - localizationParameters: The localization parameters.
    ///   - payment: The payment information.
    public init(style: FormComponentStyle = FormComponentStyle(),
                payment: Payment?,
                localizationParameters: LocalizationParameters? = nil) {
        self.style = style
        self.localizationParameters = localizationParameters
        self.payment = payment
    }
}

/// The configuration of any component thats aware of shoppers' personal information.
public struct PersonalInformationConfiguration: AnyPersonalInformationConfiguration {

    public var payment: Payment?

    public var style: FormComponentStyle
    
    public var shopperInformation: PrefilledShopperInformation?
    
    public var localizationParameters: LocalizationParameters?
    
    /// Initializes a new instance of `PersonalInformationConfiguration`
    ///
    /// - Parameters:
    ///   - style: The form style.
    ///   - shopperInformation: The shopper information to be prefilled.
    ///   - localizationParameters: The localization parameters.
    ///   - payment: The payment information.
    public init(style: FormComponentStyle = FormComponentStyle(),
                payment: Payment?,
                shopperInformation: PrefilledShopperInformation? = nil,
                localizationParameters: LocalizationParameters? = nil) {
        self.style = style
        self.shopperInformation = shopperInformation
        self.localizationParameters = localizationParameters
        self.payment = payment
    }
}
