//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import WebKit

/// Provides the device default browser info.
public struct BrowserInfo: Encodable {
    
    /// The device default user-agent.
    public var userAgent: String?
    
    @MainActor public static func initialize() async -> BrowserInfo? {
        guard cachedUserAgent == nil else {
            return BrowserInfo(userAgent: cachedUserAgent)
        }
        return await withCheckedContinuation { continuation in
            webView = WKWebView()
            webView?.evaluateJavaScript("navigator.userAgent") { result, _ in
                webView = nil
                guard let result = result as? String else {
                    continuation.resume(returning: nil)
                    return
                }
                BrowserInfo.cachedUserAgent = result
                continuation.resume(returning: BrowserInfo(userAgent: result))
            }
        }
    }
    
    private static var webView: WKWebView?
    
    internal static var cachedUserAgent: String?
}
