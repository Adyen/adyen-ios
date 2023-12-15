//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user can receive the code needed to interact with the Twint SDK.
public final class TwintSDKAction: Decodable {
    
    // TODO: Maybe we need the paymentdata and a nested object like `WeChatPaySDKAction`
    
    /// The Twint SDK code to be sent on ``Twint.pay(withCode:appConfiguration:callback:)``
    public let token: String
}
