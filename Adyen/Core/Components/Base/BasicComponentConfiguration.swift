//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public protocol AnyBasicComponentConfiguration: Localizable {
    
    var style: FormComponentStyle { get }
}

/// :nodoc:
public protocol AnyPersonalInformationConfiguration: AnyBasicComponentConfiguration {
    
    var shopperInformation: PrefilledShopperInformation? { get }
}

/// :nodoc:
public struct BasicComponentConfiguration: AnyBasicComponentConfiguration {
    
    public var style: FormComponentStyle
    
    public var localizationParameters: LocalizationParameters?
    
    public init(style: FormComponentStyle = FormComponentStyle(),
                localizationParameters: LocalizationParameters? = nil) {
        self.style = style
        self.localizationParameters = localizationParameters
    }
}

/// :nodoc:
public struct PersonalInformationConfiguration: AnyPersonalInformationConfiguration {
    public var style: FormComponentStyle
    
    public var shopperInformation: PrefilledShopperInformation?
    
    public var localizationParameters: LocalizationParameters?
    
    public init(style: FormComponentStyle = FormComponentStyle(),
                shopperInformation: PrefilledShopperInformation? = nil,
                localizationParameters: LocalizationParameters? = nil) {
        self.style = style
        self.shopperInformation = shopperInformation
        self.localizationParameters = localizationParameters
    }
}
