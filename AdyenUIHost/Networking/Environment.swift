//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal enum DemoServerEnvironment: APIEnvironment {
    
    case beta, test
    
    internal var baseUrl: URL {
        switch self {
        case .beta:
            return URL(string: "https://checkoutshopper-beta.adyen.com/checkoutshopper/demoserver/")!
        case .test:
            return URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/")!
        }
    }
}
