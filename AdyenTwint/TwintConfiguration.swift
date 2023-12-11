//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

public extension TwintComponent {
    
    struct Configuration: AnyTwintConfiguration {
        
        /// The URL for Cash App to call in order to redirect back to your application.
        public let redirectURL: URL
        
        /// Describes the component's UI style.
        public var style: FormComponentStyle

        /// The localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?
        
        public init(
            redirectURL: URL,
            style: FormComponentStyle,
            localizationParameters: LocalizationParameters? = nil
        ) {
            self.redirectURL = redirectURL
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
}

