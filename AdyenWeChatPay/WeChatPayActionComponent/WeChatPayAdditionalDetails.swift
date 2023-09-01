//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

final class WeChatPayAdditionalDetails: AdditionalDetails {
    
    let resultCode: String
    
    init(resultCode: String) {
        self.resultCode = resultCode
    }
    
}
