//
//  BACSDirectDebitRouterProtocolMock.swift
//  AdyenUIKitTests
//
//  Created by Naufal Aros on 12/2/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import Foundation

class BACSDirectDebitComponentTrackerProtocolMock: BACSDirectDebitComponentTrackerProtocol {

    // MARK: - sendEvent

    var sendTelemetryEventCallsCount = 0
    var sendTelemetryEventCalled: Bool {
        sendTelemetryEventCallsCount > 0
    }

    func sendTelemetryEvent() {
        sendTelemetryEventCallsCount += 1
    }
}
