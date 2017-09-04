//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Instances of conforming types provide additional logic for a payment method, such as an interface to enter payment details.
internal protocol Plugin {
    
    /// The configuration of the plugin.
    var configuration: PluginConfiguration { get }
    
    /// Initializes the plugin.
    ///
    /// - Parameter configuration: The configuration of the plugin.
    init(configuration: PluginConfiguration)
    
}

internal protocol PluginRequiresFinalState: Plugin {
    
    /// Provides an opportunity for a plugin to execute asynchronous logic based on the result of a completed payment.
    ///
    /// - Parameters:
    ///   - paymentStatus: The status of the completed payment.
    ///   - completion: The completion handler to invoke when the plugin is done executing.
    func finish(with paymentStatus: PaymentStatus, completion: @escaping () -> Void)
    
}

internal protocol DeviceDependablePlugin: Plugin {
    
    /// Boolean value indicating whether the current device is supported.
    var isDeviceSupported: Bool { get }
    
}

internal protocol CardScanPlugin: Plugin {
    
    /// Handler for card scan button.
    var cardScanButtonHandler: ((@escaping CardScanCompletion) -> Void)? { get set }
    
}

internal protocol UniversalLinksPlugin: Plugin {
    
    var supportsUniversalLinks: Bool { get }
}

/// Structure containing the configuration of a plugin.
internal struct PluginConfiguration {
    
    /// The payment method for which the plugin is used.
    internal let paymentMethod: PaymentMethod
    
    /// The payment setup.
    internal let paymentSetup: PaymentSetup
    
}
