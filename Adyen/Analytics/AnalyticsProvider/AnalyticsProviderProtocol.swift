//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public protocol AnyInitialAnalyticsProvider {
    
    /// Sends the initial data and retrieves the checkout attempt id as a response.
    func sendInitialAnalytics(with flavor: AnalyticsFlavor, additionalFields: AdditionalAnalyticsFields?)
}

@_spi(AdyenInternal)
public protocol AnyEventAnalyticsProvider {
    
    var checkoutAttemptId: String? { get set }
    
    /// Adds an info event to be sent.
    func add(info: AnalyticsEventInfo)
    
    /// Adds a log event to be sent.
    func add(log: AnalyticsEventLog)
    
    /// Adds an error event to be sent.
    func add(error: AnalyticsEventError)
}

@_spi(AdyenInternal)
public protocol AnyAnalyticsProvider: AnyInitialAnalyticsProvider, AnyEventAnalyticsProvider {}
