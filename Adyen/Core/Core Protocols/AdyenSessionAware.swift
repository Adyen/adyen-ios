//
// Copyright (c) 2017 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@MainActor
package protocol AdyenSessionAware {
    var isSession: Bool { get }
}
