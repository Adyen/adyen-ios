//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public protocol AnyBasicComponentConfiguration: Localizable {
    
    var style: FormComponentStyle { get }
}

public protocol AnyPersonalInformationConfiguration: AnyBasicComponentConfiguration {
    
    var shopperInformation: PrefilledShopperInformation? { get }
}

public struct BasicComponentConfiguration: AnyBasicComponentConfiguration {
    
    public let style: FormComponentStyle
    
    public var localizationParameters: LocalizationParameters?
    
    public init(style: FormComponentStyle = FormComponentStyle(),
                localizationParameters: LocalizationParameters? = nil) {
        self.style = style
        self.localizationParameters = localizationParameters
    }
}

public struct PersonalInformationConfiguration: AnyPersonalInformationConfiguration {
    public let style: FormComponentStyle
    
    public let shopperInformation: PrefilledShopperInformation?
    
    public var localizationParameters: LocalizationParameters?
    
    public init(style: FormComponentStyle = FormComponentStyle(),
                shopperInformation: PrefilledShopperInformation? = nil,
                localizationParameters: LocalizationParameters? = nil) {
        self.style = style
        self.shopperInformation = shopperInformation
        self.localizationParameters = localizationParameters
    }
}
