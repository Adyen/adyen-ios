//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import WebKit

/// Provides the device default browser info.
public struct BrowserInfo: Encodable {
    
    /// The device default user-agent.
    public var userAgent: String?

    /// The Accept request HTTP header indicates which content types, expressed as MIME types, the client is able to understand.
    public var acceptHeader: String { "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" }
    
    /// Initializes a `BrowserInfo` instance asynchronously.
    ///
    /// - Parameters:
    ///   - completion: A call back when the `BrowserInfo` instance is ready or when initialization fails.
    public static func initialize(completion: @escaping ((_ info: BrowserInfo?) -> Void)) {
        guard cachedUserAgent == nil else {
            completion(BrowserInfo(userAgent: cachedUserAgent))
            return
        }
        webView = WKWebView()
        webView?.evaluateJavaScript("navigator.userAgent") { result, _ in
            webView = nil
            guard let result = result as? String else {
                return completion(nil)
            }
            BrowserInfo.cachedUserAgent = result
            completion(BrowserInfo(userAgent: cachedUserAgent))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(acceptHeader, forKey: .acceptHeader)
        try container.encodeIfPresent(userAgent, forKey: .userAgent)
    }
    
    /// :nodoc:
    private static var webView: WKWebView?
    
    /// :nodoc:
    private static var cachedUserAgent: String?

    private enum CodingKeys: String, CodingKey {
        case userAgent
        case acceptHeader
    }
}
