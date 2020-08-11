//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

extension Request {
    internal var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "x-demo-server-api-key": Configuration.demoServerAPIKey
        ]
    }
}
