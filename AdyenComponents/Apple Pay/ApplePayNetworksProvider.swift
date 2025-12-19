//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

internal protocol ApplePayNetworksProviding {
    func availableNetworks() -> [PKPaymentNetwork]
}

internal struct ApplePayNetworksProvider: ApplePayNetworksProviding {

    internal func availableNetworks() -> [PKPaymentNetwork] {
        PKPaymentRequest.availableNetworks()
    }
}
