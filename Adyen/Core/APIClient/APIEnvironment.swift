//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents any API and its different environments (test, beta, and live).
public protocol APIEnvironment {
    
    /// The base url.
    var baseUrl: URL { get }
    
}
