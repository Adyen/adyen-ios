//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

/// This function should be invoked from the application's delegate when the application is opened through a URL.
///
/// - Parameter url: The URL through which the application was opened.
/// - Returns: A boolean value indicating whether the URL was handled by the Adyen SDK.
@discardableResult
public func applicationDidOpen(_ url: URL) -> Bool {
    return RedirectListener.applicationDidOpen(url)
}
