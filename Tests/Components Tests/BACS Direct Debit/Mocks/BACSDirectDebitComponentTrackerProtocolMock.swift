//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import Foundation

class BACSDirectDebitComponentTrackerProtocolMock: BACSDirectDebitComponentTrackerProtocol {

    // MARK: - sendEvent

    var initialEventCallsCount = 0
    
    func sendInitialAnalytics() {
        initialEventCallsCount += 1
    }
    
    var didLoadEventCallsCount = 0
    func sendDidLoadEvent() {
        didLoadEventCallsCount += 1
    }
}
