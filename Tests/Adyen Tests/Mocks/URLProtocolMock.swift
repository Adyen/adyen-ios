//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

// MARK: - Image

class ImageResponseURLProtocolMock: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        client?.urlProtocol(self, didReceive: .init(), cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: request.url!.absoluteString.generateImage()!.pngData()!)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

// MARK: - Failing

class FailingURLProtocolMock: URLProtocol {
    
    struct URLProtocolError: Error {}
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        client?.urlProtocol(self, didFailWithError: URLProtocolError())
    }
    
    override func stopLoading() {}
}
