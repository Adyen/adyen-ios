//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import WebKit

/// Provides the device default browser info.
package struct BrowserInfo: Encodable {

    internal static var cachedUserAgent: String?

    /// The device default user-agent.
    package let userAgent: String

    /// Initializes a `BrowserInfo` instance asynchronously by retrieving the device's user agent.
    ///
    /// - Returns: A `BrowserInfo` instance if the user agent was successfully retrieved, or `nil` if the evaluation failed.
    @MainActor package init?() async {
        if let cached = Self.cachedUserAgent {
            self.userAgent = cached
            return
        }

        let webView = WKWebView()
        guard let userAgent = try? await webView.evaluateJavaScript("navigator.userAgent") as? String else {
            return nil
        }

        self.userAgent = userAgent
        BrowserInfo.cachedUserAgent = userAgent
    }
}
