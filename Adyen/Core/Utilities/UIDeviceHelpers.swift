//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal extension UIDevice {
    /// Returns the identifier of the device model, such as iPhone10,3 for iPhone X.
    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let deviceModelData = Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN))
        let deviceModel = String(bytes: deviceModelData, encoding: .ascii).map { $0.trimmingCharacters(in: .controlCharacters) }
        
        // As a fallback, use the UIDevice model property (which doesn't include the model version).
        return deviceModel ?? UIDevice.current.model
    }
    
}
