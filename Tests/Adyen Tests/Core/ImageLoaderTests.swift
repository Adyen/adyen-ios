//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
import XCTest

class ImageLoaderTests: XCTestCase {
    
    func test_loading_shouldCallCompletion() {
        
        let imageLoader = makeSUT()
        let completionExpectation = expectation(description: "Nil image was provided")
        completionExpectation.expectedFulfillmentCount = 5

        (0..<5).forEach { _ in
            imageLoader.load(url: URL(string: "https://adyen.com")!) { image in
                XCTAssertNotNil(image)
                completionExpectation.fulfill()
            }
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
    
    func test_cancelLoading_shouldNotCallCompletion() {
        
        let imageLoader = makeSUT()
        let noCompletionExpectation = expectation(description: "No image was provided")
        noCompletionExpectation.isInverted = true
        
        (0..<5).forEach { _ in
            let cancellable = imageLoader.load(url: URL(string: "https://adyen.com")!) { image in
                noCompletionExpectation.fulfill()
            }
            cancellable.cancel()
        }
        
        wait(for: [noCompletionExpectation], timeout: 1)
    }
    
    func test_cancelLoadingMultipleImages_shouldCallCompletionCorrectly() {
        
        let imageLoader = makeSUT()
        let completionExpectation = expectation(description: "Nil image was provided")
        completionExpectation.expectedFulfillmentCount = 5
        
        let noCompletionExpectation = expectation(description: "No image was provided")
        noCompletionExpectation.isInverted = true
        
        (0..<5).forEach { _ in
            imageLoader.load(url: URL(string: "https://adyen.com")!) { image in
                XCTAssertNotNil(image)
                completionExpectation.fulfill()
            }
        }
        
        (0..<5).forEach { _ in
            let cancellable = imageLoader.load(url: URL(string: "https://adyen.com")!) { image in
                noCompletionExpectation.fulfill()
            }
            cancellable.cancel()
        }
        
        wait(for: [noCompletionExpectation, completionExpectation], timeout: 0.1)
    }
}

private extension ImageLoaderTests {
    
    func makeSUT() -> ImageLoader {
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [ImageResponseURLProtocolMock.self]
        
        let urlSession = URLSession(configuration: configuration)
        return ImageLoader(urlSession: urlSession)
    }
}
