//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

internal protocol ExampleComponentProtocol {
    var apiClient: APIClientProtocol { get }
    func start()
}

extension ExampleComponentProtocol {
    
    internal static var context: AdyenContext {
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = ConfigurationConstants.current.analyticsSettings.isEnabled
        return AdyenContext(apiContext: ConfigurationConstants.apiContext,
                            payment: ConfigurationConstants.current.payment,
                            analyticsConfiguration: analyticsConfiguration)
    }
}
