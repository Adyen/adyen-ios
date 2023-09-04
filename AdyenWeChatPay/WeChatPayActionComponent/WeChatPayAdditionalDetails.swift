//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
final class WeChatPayAdditionalDetails: AdditionalDetails {
    
    /// :nodoc:
    let resultCode: String
    
    /// :nodoc:
    init(resultCode: String) {
        self.resultCode = resultCode
    }
    
}
