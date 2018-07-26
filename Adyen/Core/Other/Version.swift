//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The version of the SDK, read from the info property list.
internal let sdkVersion: String = {
    let bundle = Bundle(for: PaymentController.self)
    guard let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String else {
        fatalError("Failed to read version number from Info.plist.")
    }
    
    return version
}()
