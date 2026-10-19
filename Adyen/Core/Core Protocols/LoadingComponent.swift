//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any `Component` that show a loading state of some kind
package protocol LoadingComponent {
    /// Stops any processing animation that the view controller is running.
    ///
    func stopLoading()
}
