//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum DemoServerEnvironment {
    
    case beta, test
    
    internal var url: URL {
        switch self {
        case .beta:
            return URL(string: "https://checkoutshopper-beta.adyen.com/checkoutshopper/demoserver/")!
        case .test:
            return URL(string: "https://checkoutshopper-test.adyen.com/checkoutshopper/demoserver/")!
        }
    }
}
