//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import WebKit

/// Provides the device default browser info.
public struct BrowserInfo: Encodable {

    internal static var cachedUserAgent: String?

    /// The device default user-agent.
    public let userAgent: String

    @MainActor internal var webView: WKWebView?

    private enum CodingKeys: CodingKey {
        case userAgent
    }

    @MainActor public init?() async {
        if let cached = Self.cachedUserAgent {
            self.userAgent = cached
            return
        }

        self.webView = WKWebView()
        guard let userAgent = try? await webView?.evaluateJavaScript("navigator.userAgent") as? String else {
            return nil
        }
        self.webView = nil
        
        self.userAgent = userAgent
        BrowserInfo.cachedUserAgent = userAgent
    }
}
