//
//  BACSDirectDebitComponentTrackerProtocolMock.swift
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

    var initialEventCallsCount = 0
    
    func sendInitialAnalytics() {
        initialEventCallsCount += 1
    }
    
    var didLoadEventCallsCount = 0
    func sendDidLoadEvent() {
        didLoadEventCallsCount += 1
    }
}
