//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

var sdkVersion: String {
    let bundle = Bundle(for: PaymentRequest.self)
    guard let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String else {
        fatalError("Failed to read version number from Info.plist.")
    }
    
    return version
}
