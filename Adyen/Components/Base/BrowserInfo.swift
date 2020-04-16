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
    public var userAgent: String? { BrowserInfo.cachedUserAgent }
    
    /// Initializes a `BrowserInfo` instance asynchronously.
    ///
    /// - Parameters:
    ///   - completion: A call back when the `BrowserInfo` instance is ready or when initialization fails.
    public static func initialize(completion: @escaping ((_ info: BrowserInfo?) -> Void)) {
        guard cachedUserAgent == nil else {
            completion(BrowserInfo())
            return
        }
        webView = WKWebView()
        webView?.evaluateJavaScript("navigator.userAgent") { result, _ in
            webView = nil
            guard let result = result as? String else { completion(nil); return }
            BrowserInfo.cachedUserAgent = result
            completion(BrowserInfo())
        }
    }
    
    /// :nodoc:
    private static var webView: WKWebView?
    
    /// :nodoc:
    private static var cachedUserAgent: String?
}
