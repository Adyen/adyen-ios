//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents any structure/object whose behavior is device dependent.
/// :nodoc:
public protocol DeviceDependent {
    
    /// Decides whether current device is supported.
    static func isDeviceSupported() -> Bool
    
}
