//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenComponents
import Foundation
import PassKit

final class ApplePayNetworksProvidingMock: ApplePayNetworksProviding {

    // MARK: - availableNetworks

    private(set) var availableNetworksCallsCount = 0
    var availableNetworksCalled: Bool {
        availableNetworksCallsCount > 0
    }

    var availableNetworksReturnValue: [PKPaymentNetwork] = []

    func availableNetworks() -> [PKPaymentNetwork] {
        availableNetworksCallsCount += 1
        return availableNetworksReturnValue
    }
}
