//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to the Twint SDK.
public final class TwintSDKAction: Decodable {

    /// The TwintSDK specific data.
    public let sdkData: TwintSDKData

    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String

    // The payment method type
    public let paymentMethodType: String

    // The payment method subtype
    public let type: String

}
