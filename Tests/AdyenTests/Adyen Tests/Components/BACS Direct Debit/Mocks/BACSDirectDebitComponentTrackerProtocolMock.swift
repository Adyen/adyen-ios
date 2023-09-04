//
//  BACSDirectDebitComponentTrackerProtocolMock.swift
//  AdyenUIKitTests
//
//  Created by Naufal Aros on 12/2/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenComponents
import Foundation

class BACSDirectDebitComponentTrackerProtocolMock: BACSDirectDebitComponentTrackerProtocol {

    // MARK: - sendEvent

    var sendEventCallsCount = 0
    var sendEventCalled: Bool {
        sendEventCallsCount > 0
    }

    func sendEvent() {
        sendEventCallsCount += 1
    }
}
