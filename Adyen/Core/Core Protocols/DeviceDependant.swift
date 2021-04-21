//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents any structure/object whose behaviour is device dependant.
/// :nodoc:
public protocol DeviceDependant {
    
    /// Decides whether curret device is supported.
    static func isDeviceSupported() -> Bool
    
}
