//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenSwiftUI
import SwiftUI
import XCTest

final class FullScreenViewControllerTests: XCTestCase {
    
    func testViewControllerIsPresented() {
        let expectation = expectation(description: "View controller is presented")
        
        let viewModel = TestPresentingViewModel()
        let testVC = UIViewController()
        
        let view = TestPresentingView(viewModel: viewModel)
        let host = UIHostingController(rootView: view)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = host
        window.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            viewModel.viewController = testVC
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            XCTAssertTrue(host.presentedViewController === testVC, "Expected view controller to be presented")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
