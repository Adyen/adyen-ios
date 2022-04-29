//
//  AnalyticsProviderMock.swift
//  AdyenUIHost
//
//  Created by Naufal Aros on 4/11/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Foundation
@testable import Adyen

class AnalyticsProviderMock: AnalyticsProviderProtocol {

    // MARK: - trackTelemetryEvent

    var trackTelemetryEventCallsCount = 0
    var trackTelemetryEventCalled: Bool {
        trackTelemetryEventCallsCount > 0
    }

    func trackTelemetryEvent(flavor: TelemetryFlavor) {
        trackTelemetryEventCallsCount += 1
    }
}
