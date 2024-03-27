//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
import XCTest

class ImageLoaderTests: XCTestCase {
    
    private let dummyImageUrl: URL = URL(string: "https://adyen.com")!
    
    func test_instantiatingImageLoader_doesNotHaveAnySideEffects() {
        
        // Given
        
        let imageLoader = makeSUT()
        let getAllTasksIsCalled = expectation(description: "urlSession.getAllTasks is called")
        
        // When: Loading a couple of images
        
        imageLoader.urlSession.getAllTasks { tasks in
            
            // Then: No tasks should have been created on the urlSession
            
            XCTAssertTrue(tasks.isEmpty)
            getAllTasksIsCalled.fulfill()
        }
        
        wait(for: [getAllTasksIsCalled], timeout: 1)
    }
    
    func test_loading_shouldCallCompletionOnMainThread() {
        
        // Given
        
        let imageLoader = makeSUT()
        let completionExpectation = expectation(description: "Non-nil image was provided")
        completionExpectation.expectedFulfillmentCount = 5

        // When: Loading a couple of images
        
        (0..<5).forEach { _ in
            imageLoader.load(url: dummyImageUrl) { image in
                
                // Then: All completion handlers are called
                
                XCTAssertTrue(Thread.isMainThread)
                XCTAssertNotNil(image)
                completionExpectation.fulfill()
            }
        }
        
        wait(for: [completionExpectation], timeout: 1)
    }
    
    func test_cancelLoading_shouldNotCallCompletion() {
        
        // Given
        
        let imageLoader = makeSUT()
        let noCompletionExpectation = expectation(description: "Completion was not called")
        noCompletionExpectation.isInverted = true
        
        // When: Loading a couple of images and cancelling all
        
        (0..<5).forEach { _ in
            let cancellable = imageLoader.load(url: dummyImageUrl) { image in
                
                // Then: No completion handler was called
                
                noCompletionExpectation.fulfill()
            }
            cancellable.cancel()
        }
        
        wait(for: [noCompletionExpectation], timeout: 1)
    }
    
    func test_cancelLoadingMultipleImages_shouldCallCompletionCorrectly() {
        
        // Given
        
        let imageLoader = makeSUT()
        let completionExpectation = expectation(description: "Non-nil image was provided")
        completionExpectation.expectedFulfillmentCount = 5
        
        let noCompletionExpectation = expectation(description: "Completion was not called")
        noCompletionExpectation.isInverted = true
        
        // When: Loading a couple of images and cancelling some
        
        (0..<5).forEach { _ in
            imageLoader.load(url: dummyImageUrl) { image in
                
                // Then: The loading completion handler is called the right amount of times
                
                XCTAssertNotNil(image)
                completionExpectation.fulfill()
            }
        }
        
        (0..<5).forEach { _ in
            let cancellable = imageLoader.load(url: dummyImageUrl) { image in
                
                // Then: The loading completion handler is called the right amount of times
                
                noCompletionExpectation.fulfill()
            }
            cancellable.cancel()
        }
        
        wait(for: [noCompletionExpectation, completionExpectation], timeout: 0.1)
    }
    
    func test_errorResponse_shouldCallCompletionWithNilImage() {
        
        // Given: Failing image loader
        
        let imageLoader = makeSUT(shouldFail: true)
        let completionExpectation = expectation(description: "Nil image was provided")
        
        // When: Triggering a failing loading
        
        imageLoader.load(url: dummyImageUrl) { image in
            
            // Then: The completion handler provides a nil image
            
            XCTAssertNil(image)
            completionExpectation.fulfill()
        }
        
        wait(for: [completionExpectation], timeout: 0.1)
    }
    
    func test_deallocatingImageLoader_shouldNotCallCompletion() throws {
        
        // Given
        
        var imageLoader: ImageLoader? = makeSUT()
        let noCompletionExpectation = expectation(description: "Completion was not called")
        noCompletionExpectation.isInverted = true
        
        // When: Loading a an image and deallocating the imageLoader before an image was loaded
        
        try XCTUnwrap(imageLoader).load(url: dummyImageUrl) { image in
            
            // Then: No completion handler was called
            
            noCompletionExpectation.fulfill()
        }
        
        imageLoader = nil
        
        wait(for: [noCompletionExpectation], timeout: 1)
    }
    
    // MARK: - UIImageView Extension Tests
    
    func test_imageViewExtensionLogic_updatesImageCorrectly() {
        
        // Given
        
        let imageLoader = makeSUT()
        let imageView = UIImageView()
        
        // When: Triggering loading
        
        imageView.load(url: dummyImageUrl, using: imageLoader)
        
        // Then: The image is nil during loading
        
        XCTAssertNil(imageView.image)
        
        // Then: The image is set after being loaded
        
        wait { imageView.image != nil }
    }
    
    func test_imageViewExtensionLogic_appliesPlaceholderCorrectly() {
        
        // Given
        
        let imageLoader = makeSUT()
        let imageView = UIImageView()
        let placeholderImage = UIImage(systemName: "photo")
        
        // When: Triggering the first load
        
        imageView.load(url: dummyImageUrl, using: imageLoader, placeholder: placeholderImage)
        
        // Then: Immediately the placeholder image is applied
        
        XCTAssertTrue(imageView.image === placeholderImage)
        
        // Then: Placeholder is replaced by the loaded image
        
        wait {
            imageView.image !== placeholderImage && imageView.image != nil
        }
        
        // When: Triggering loading again
        
        imageView.load(url: dummyImageUrl, using: imageLoader, placeholder: placeholderImage)
        
        // Then: The placeholder is applied during the loading process regardless of the current image
        
        XCTAssertTrue(imageView.image === placeholderImage)
    }
}

private extension ImageLoaderTests {
    
    func makeSUT(shouldFail: Bool = false) -> ImageLoader {
        
        let configuration = URLSessionConfiguration.default
        if shouldFail {
            configuration.protocolClasses = [FailingURLProtocolMock.self]
        } else {
            configuration.protocolClasses = [ImageResponseURLProtocolMock.self]
        }
        
        let urlSession = URLSession(configuration: configuration)
        return ImageLoader(urlSession: urlSession)
    }
}
