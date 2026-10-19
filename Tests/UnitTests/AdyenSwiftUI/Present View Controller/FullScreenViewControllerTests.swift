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
        let viewModel = TestPresentingViewModel()
        let testVC = UIViewController()
        
        let view = TestPresentingView(viewModel: viewModel)
        let host = UIHostingController(rootView: view)
        
        guard let windowScene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
            return XCTFail("Expected an active window scene")
        }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = host
        window.makeKeyAndVisible()
        wait(for: .seconds(1))

        DispatchQueue.main.async {
            viewModel.viewController = testVC
        }
        
        let predicate = NSPredicate { _, _ in host.presentedViewController === testVC }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: host)
        wait(for: [expectation], timeout: 5.0)
    }
}
