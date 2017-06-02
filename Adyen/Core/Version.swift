//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

var sdkVersion: String {
    if let file = Bundle(for: PaymentRequest.self).path(forResource: "VERSION", ofType: ""),
        let lines = try? String(contentsOfFile: file).components(separatedBy: .newlines),
        let version = lines.first {
        return version
    }
    
    fatalError("Could not read VERSION file")
}
